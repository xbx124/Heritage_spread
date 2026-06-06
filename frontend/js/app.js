/**
 * 非遗文化数字化传播系统 - 管理系统逻辑
 * 需登录才能访问，未登录自动跳转到首页
 */

// ============================================================
// Auth 检查
// ============================================================
if (!localStorage.getItem('token')) {
  window.location.href = '/';
}

// ============================================================
// 全局状态
// ============================================================
const state = {
  token: localStorage.getItem('token') || '',
  user: JSON.parse(localStorage.getItem('user') || 'null'),
  currentPage: null,
  projPage: 1,
  projSize: 10,
  catPage: 1,
  catSize: 10,
  inhPage: 1,
  inhSize: 10,
  newsPage: 1,
  newsSize: 10,
};

// ============================================================
// API
// ============================================================
const API = {
  async request(method, url, data) {
    const h = { 'Content-Type': 'application/json' };
    if (state.token) h['Authorization'] = 'Bearer ' + state.token;
    const o = { method, headers: h };
    if (data && method !== 'GET') o.body = JSON.stringify(data);
    const r = await fetch(url, o);
    if (r.status === 401) { doLogout(); return { code: 401 }; }
    return r.json();
  },
  get(u) { return this.request('GET', u); },
  post(u, d) { return this.request('POST', u, d); },
  put(u, d) { return this.request('PUT', u, d); },
  del(u) { return this.request('DELETE', u); },
};

// ============================================================
// 侧边栏用户信息
// ============================================================
function initSidebarUser() {
  if (state.user) {
    const roleMap = { admin: '管理员', editor: '编辑', user: '用户' };
    document.getElementById('sidebar-user').innerHTML = `
            <span class="sb-username">${state.user.username}</span>
            <span class="sb-role">${roleMap[state.user.role] || '用户'}</span>
            <a href="javascript:doLogout()" class="sb-logout">退出</a>`;
  }
}

function doLogout() {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
  window.location.href = '/';
}

// ============================================================
// 权限UI
// ============================================================
function initPermissions() {
  const role = state.user ? state.user.role : '';
  document.querySelectorAll('.admin-only').forEach(el => {
    el.classList.toggle('hidden', role !== 'admin');
  });
  document.querySelectorAll('.editor-only').forEach(el => {
    el.classList.toggle('hidden', role !== 'admin' && role !== 'editor');
  });
  // 普通用户隐藏操作列
  document.querySelectorAll('.action-col').forEach(el => {
    el.classList.toggle('hidden', role === 'user');
  });
}

// ============================================================
// 页面路由
// ============================================================
function showPage(page, params) {
  state.currentPage = page;
  document.querySelectorAll('#main-content .page').forEach(p => p.style.display = 'none');
  const el = document.getElementById('page-' + page);
  if (el) el.style.display = '';
  // 侧边栏激活
  document.querySelectorAll('#sidebar .nav-item').forEach(n => n.classList.remove('active'));
  const nav = document.querySelector(`#sidebar .nav-item[data-page="${page}"]`);
  if (nav) nav.classList.add('active');
  document.getElementById('main-content').scrollTo(0, 0);
  // 加载
  const loader = {
    categories: loadCategories, projects: loadProjects,
    'project-detail': () => loadProjectDetail(params),
    inheritors: loadInheritors,
    'inheritor-detail': () => loadInheritorDetail(params),
    news: loadNews, 'news-detail': () => loadNewsDetail(params),
    'news-create': resetNewsForm, channels: loadChannels, stats: loadStats,
  };
  if (loader[page]) loader[page]();
}

// ============================================================
// 分类
// ============================================================
function loadCategories() {
  API.get(`/api/categories?page=${state.catPage}&size=${state.catSize}`).then(res => {
    if (res.code !== 200) return;
    const d = res.data;
    const totalPages = Math.ceil(d.total / state.catSize) || 1;
    document.getElementById('cat-page-info').textContent = `共 ${d.total} 条，${d.page}/${totalPages} 页`;
    document.getElementById('cat-pagination').style.display = d.total > state.catSize ? '' : 'none';
    const isAdm = state.user && state.user.role === 'admin';
    document.getElementById('categories-list').innerHTML = `<div class="table-container"><table>
            <thead><tr><th>ID</th><th>名称</th><th>描述</th>${isAdm ? '<th>操作</th>' : ''}</tr></thead>
            <tbody>${(d.list || []).map(c => `<tr><td>${c.category_id}</td><td>${c.category_name}</td><td>${c.category_desc || '-'}</td>
            ${isAdm ? `<td class="action-btns">
                <button class="btn btn-sm btn-outline" onclick="editCategory(${c.category_id},'${esc(c.category_name)}','${esc(c.category_desc || '')}')">编辑</button>
                <button class="btn btn-sm btn-danger" onclick="deleteCategory(${c.category_id})">删除</button></td>` : ''}</tr>`).join('')}</tbody></table></div>`;
  });
}
function changeCatPage(d) { state.catPage = Math.max(1, state.catPage + d); loadCategories(); }
function esc(s) { return s.replace(/'/g, "\\'").replace(/"/g, '&quot;'); }
function showCategoryForm() { resetModal('category', '新增分类'); }
function editCategory(id, n, d) { resetModal('category', '编辑分类'); document.getElementById('cat-edit-id').value = id; document.getElementById('cat-name').value = n; document.getElementById('cat-desc').value = d; }
function closeCategoryModal() { document.getElementById('category-modal').style.display = 'none'; }
function saveCategory(e) {
  e.preventDefault();
  const id = document.getElementById('cat-edit-id').value;
  const data = { category_name: document.getElementById('cat-name').value.trim(), category_desc: document.getElementById('cat-desc').value.trim() };
  if (!data.category_name) return alert('名称不能为空');
  (id ? API.put('/api/categories/' + id, data) : API.post('/api/categories', data)).then(r => {
    if (r.code === 200) { closeCategoryModal(); loadCategories(); } else alert(r.msg);
  });
}
function deleteCategory(id) { if (confirm('确定删除？')) API.del('/api/categories/' + id).then(r => { if (r.code === 200) loadCategories(); else alert(r.msg); }); }

function resetModal(type, title) {
  const modals = {
    category: ['cat-edit-id', 'cat-name', 'cat-desc', 'category-modal-title', 'category-modal'],
    project: ['proj-edit-id', 'proj-name', 'proj-area', 'proj-intro', 'proj-modal-title', 'project-modal'],
    inheritor: ['inh-edit-id', 'inh-name', 'inh-years', 'inh-intro', 'inh-modal-title', 'inheritor-modal'],
    channel: ['ch-edit-id', 'ch-name', 'ch-type', 'ch-modal-title', 'channel-modal']
  };
  const [idF, nF, aF, iF, tF, mF] = modals[type];
  document.getElementById(idF).value = '';
  document.getElementById(nF).value = '';
  if (aF) document.getElementById(aF).value = (type === 'inheritor' ? '0' : '');
  if (iF) document.getElementById(iF).value = '';
  document.getElementById(tF).textContent = title;
  document.getElementById(mF).style.display = 'flex';
}

// ============================================================
// 项目
// ============================================================
function loadProjects() {
  const kw = document.getElementById('proj-keyword').value.trim();
  const cid = document.getElementById('proj-category-filter').value;
  const area = document.getElementById('proj-area-filter').value.trim();
  let url = `/api/projects?page=${state.projPage}&size=${state.projSize}`;
  if (kw) url += '&keyword=' + encodeURIComponent(kw);
  if (cid) url += '&category_id=' + cid;
  if (area) url += '&area=' + encodeURIComponent(area);
  API.get('/api/categories?size=100').then(r => {
    if (r.code === 200) document.getElementById('proj-category-filter').innerHTML = '<option value="">全部分类</option>' + r.data.list.map(c => `<option value="${c.category_id}">${c.category_name}</option>`).join('');
  });
  API.get(url).then(res => {
    if (res.code !== 200) return;
    const d = res.data;
    const ok = state.user && (state.user.role === 'admin' || state.user.role === 'editor');
    const adm = state.user && state.user.role === 'admin';
    const isUser = state.user && state.user.role === 'user';
    document.getElementById('proj-page-info').textContent = `共 ${d.total} 条，${d.page}/${Math.ceil(d.total / state.projSize) || 1} 页`;
    document.getElementById('projects-tbody').innerHTML = (d.list || []).map(p => `<tr>
            <td>${p.project_id}</td><td><a href="javascript:showPage('project-detail',${p.project_id})" style="color:var(--cinnabar);cursor:pointer">${p.project_name}</a></td>
            <td>${p.category_name}</td><td>${p.area || '-'}</td><td>${p.inheritor_count || 0}</td><td>${p.create_time}</td>
            ${isUser ? '' : `<td class="action-btns">${ok ? `<button class="btn btn-sm btn-outline" onclick="editProject(${p.project_id})">编辑</button>` : ''}${adm ? `<button class="btn btn-sm btn-danger" onclick="deleteProject(${p.project_id})">删除</button>` : ''}</td>`}</tr>`).join('') || `<tr><td colspan="${isUser ? 6 : 7}" style="text-align:center;color:var(--text-muted)">暂无数据</td></tr>`;
  });
}
function changeProjPage(d) { state.projPage = Math.max(1, state.projPage + d); loadProjects(); }
function showProjectForm() {
  resetModal('project', '新增非遗项目');
  API.get('/api/categories?size=100').then(r => { if (r.code === 200) document.getElementById('proj-category').innerHTML = r.data.list.map(c => `<option value="${c.category_id}">${c.category_name}</option>`).join(''); });
}
function editProject(id) {
  API.get('/api/projects/' + id).then(res => {
    if (res.code !== 200) return;
    const p = res.data;
    resetModal('project', '编辑非遗项目');
    document.getElementById('proj-edit-id').value = p.project_id;
    document.getElementById('proj-name').value = p.project_name;
    document.getElementById('proj-area').value = p.area || '';
    document.getElementById('proj-intro').value = p.project_intro || '';
    API.get('/api/categories?size=100').then(cr => {
      if (cr.code === 200) document.getElementById('proj-category').innerHTML = cr.data.list.map(c => `<option value="${c.category_id}" ${c.category_id === p.category_id ? 'selected' : ''}>${c.category_name}</option>`).join('');
    });
  });
}
function closeProjectModal() { document.getElementById('project-modal').style.display = 'none'; }
function saveProject(e) {
  e.preventDefault();
  const id = document.getElementById('proj-edit-id').value;
  const d = { project_name: document.getElementById('proj-name').value.trim(), category_id: parseInt(document.getElementById('proj-category').value), area: document.getElementById('proj-area').value.trim(), project_intro: document.getElementById('proj-intro').value.trim() };
  if (!d.project_name) return alert('名称不能为空');
  (id ? API.put('/api/projects/' + id, d) : API.post('/api/projects', d)).then(r => {
    if (r.code === 200) { closeProjectModal(); state.projPage = 1; loadProjects(); } else alert(r.msg);
  });
}
function deleteProject(id) { if (confirm('确定删除？')) API.del('/api/projects/' + id).then(r => { if (r.code === 200) loadProjects(); else alert(r.msg); }); }
function loadProjectDetail(id) {
  API.get('/api/projects/' + id).then(res => {
    if (res.code !== 200) { document.getElementById('project-detail-content').innerHTML = '<p style="color:var(--cinnabar);text-align:center;padding:40px">不存在</p>'; return; }
    const p = res.data;
    document.getElementById('project-detail-content').innerHTML = `<div class="detail-box">
            <div class="detail-title">${p.project_name}</div>
            <div class="detail-meta">分类：${p.category_name} | 地区：${p.area || '暂无'} | ${p.create_time}</div>
            <div class="detail-body">${p.project_intro || '暂无'}</div>
            <div class="detail-inheritors"><h4>传承人(${(p.inheritors || []).length})</h4>${(p.inheritors || []).map(i => `<div class="inheritor-card" onclick="showPage('inheritor-detail',${i.inheritor_id})"><h5>${i.name}</h5><p>从业${i.years}年 | ${(i.intro || '').substring(0, 60)}...</p></div>`).join('') || '<p style="color:var(--text-muted)">暂无</p>'}</div></div>`;
  });
}

// ============================================================
// 传承人
// ============================================================
function loadInheritors() {
  const kw = document.getElementById('inh-keyword').value.trim();
  const pid = document.getElementById('inh-project-filter').value;
  let url = `/api/inheritors?page=${state.inhPage}&size=${state.inhSize}`;
  const params = [];
  if (kw) params.push('keyword=' + encodeURIComponent(kw));
  if (pid) params.push('project_id=' + pid);
  if (params.length) url += '&' + params.join('&');
  API.get('/api/projects?size=50').then(pr => {
    if (pr.code === 200) document.getElementById('inh-project-filter').innerHTML = '<option value="">全部项目</option>' + (pr.data.list || []).map(p => `<option value="${p.project_id}">${p.project_name}</option>`).join('');
  });
  API.get(url).then(res => {
    if (res.code !== 200) return;
    const d = res.data;
    const list = d.list || [];
    const totalPages = Math.ceil(d.total / state.inhSize) || 1;
    document.getElementById('inh-page-info').textContent = `共 ${d.total} 条，${d.page}/${totalPages} 页`;
    const ok = state.user && (state.user.role === 'admin' || state.user.role === 'editor');
    const adm = state.user && state.user.role === 'admin';
    const isUser = state.user && state.user.role === 'user';
    document.getElementById('inheritors-tbody').innerHTML = list.map(i => `<tr>
            <td>${i.inheritor_id}</td><td><a href="javascript:showPage('inheritor-detail',${i.inheritor_id})" style="color:var(--cinnabar);cursor:pointer">${i.name}</a></td>
            <td>${i.project_name || '-'}</td><td>${i.years || 0}年</td>
            ${isUser ? '' : `<td class="action-btns">${ok ? `<button class="btn btn-sm btn-outline" onclick="editInheritor(${i.inheritor_id})">编辑</button>` : ''}${adm ? `<button class="btn btn-sm btn-danger" onclick="deleteInheritor(${i.inheritor_id})">删除</button>` : ''}</td>`}</tr>`).join('') || `<tr><td colspan="${isUser ? 4 : 5}" style="text-align:center;color:var(--text-muted)">暂无数据</td></tr>`;
  });
}
function changeInhPage(d) { state.inhPage = Math.max(1, state.inhPage + d); loadInheritors(); }
function showInheritorForm() {
  resetModal('inheritor', '新增传承人');
  API.get('/api/projects?size=50').then(r => { if (r.code === 200) document.getElementById('inh-project').innerHTML = (r.data.list || []).map(p => `<option value="${p.project_id}">${p.project_name}</option>`).join(''); });
}
function editInheritor(id) {
  API.get('/api/inheritors/' + id).then(res => {
    if (res.code !== 200) return;
    const i = res.data;
    resetModal('inheritor', '编辑传承人');
    document.getElementById('inh-edit-id').value = i.inheritor_id;
    document.getElementById('inh-name').value = i.name;
    document.getElementById('inh-years').value = i.years || 0;
    document.getElementById('inh-intro').value = i.intro || '';
    API.get('/api/projects?size=50').then(pr => {
      if (pr.code === 200) document.getElementById('inh-project').innerHTML = (pr.data.list || []).map(p => `<option value="${p.project_id}" ${p.project_id === i.project_id ? 'selected' : ''}>${p.project_name}</option>`).join('');
    });
  });
}
function closeInheritorModal() { document.getElementById('inheritor-modal').style.display = 'none'; }
function saveInheritor(e) {
  e.preventDefault();
  const id = document.getElementById('inh-edit-id').value;
  const d = { name: document.getElementById('inh-name').value.trim(), project_id: parseInt(document.getElementById('inh-project').value), years: parseInt(document.getElementById('inh-years').value) || 0, intro: document.getElementById('inh-intro').value.trim() };
  if (!d.name) return alert('姓名不能为空');
  (id ? API.put('/api/inheritors/' + id, d) : API.post('/api/inheritors', d)).then(r => { if (r.code === 200) { closeInheritorModal(); loadInheritors(); } else alert(r.msg); });
}
function deleteInheritor(id) { if (confirm('确定删除？')) API.del('/api/inheritors/' + id).then(r => { if (r.code === 200) loadInheritors(); else alert(r.msg); }); }
function loadInheritorDetail(id) {
  API.get('/api/inheritors/' + id).then(res => {
    if (res.code !== 200) { document.getElementById('inheritor-detail-content').innerHTML = '<p style="color:var(--cinnabar);text-align:center;padding:40px">不存在</p>'; return; }
    const i = res.data;
    document.getElementById('inheritor-detail-content').innerHTML = `<div class="detail-box"><div class="detail-title">${i.name}</div><div class="detail-meta">项目：<a href="javascript:showPage('project-detail',${i.project_id})" style="color:var(--cinnabar)">${i.project_name || '-'}</a> | 从业${i.years || 0}年</div><div class="detail-body">${i.intro || '暂无'}</div></div>`;
  });
}

// ============================================================
// 资讯
// ============================================================
function loadNews() {
  API.get(`/api/news?page=${state.newsPage}&size=${state.newsSize}`).then(res => {
    if (res.code !== 200) return;
    const d = res.data;
    document.getElementById('news-page-info').textContent = `共 ${d.total} 条，${d.page}/${Math.ceil(d.total / state.newsSize) || 1} 页`;
    document.getElementById('news-list').innerHTML = (d.list || []).map(n => `<div class="news-list-item" onclick="showPage('news-detail',${n.news_id})"><h4>${n.title}</h4><div class="news-meta"><span>${n.author}</span><span>${n.publish_time}</span></div></div>`).join('') || '<p style="text-align:center;color:var(--text-muted);padding:40px">暂无</p>';
  });
}
function changeNewsPage(d) { state.newsPage = Math.max(1, state.newsPage + d); loadNews(); }
function loadNewsDetail(id) {
  API.get('/api/news/' + id).then(res => {
    if (res.code !== 200) { document.getElementById('news-detail-content').innerHTML = '<p style="color:var(--cinnabar);text-align:center;padding:40px">不存在</p>'; document.getElementById('news-comments').innerHTML = ''; return; }
    const n = res.data;
    const can = state.user && (state.user.role === 'admin' || state.user.username === n.author);
    document.getElementById('news-detail-content').innerHTML = `<div class="news-detail"><div class="news-title">${n.title}</div><div class="news-meta"><span>${n.author}</span><span>${n.publish_time}</span>${can ? `<span><a href="javascript:editNews(${n.news_id})" style="color:var(--cinnabar);cursor:pointer">编辑</a><a href="javascript:deleteNews(${n.news_id})" style="color:var(--cinnabar);cursor:pointer;margin-left:8px">删除</a></span>` : ''}</div><div class="news-body">${n.content || ''}</div></div>`;
    const cmts = n.comments || [];
    let h = `<div class="comments-section"><h4>评论(${n.comments_count || cmts.length})</h4>`;
    cmts.forEach(c => { h += `<div class="comment-item"><span class="comment-user">${c.username}</span><span class="comment-time">${c.create_time}</span><div class="comment-content">${c.content}</div></div>`; });
    if (state.user) h += `<div class="comment-form"><textarea id="comment-text" placeholder="写下评论..."></textarea><button class="btn btn-filled" onclick="submitComment(${n.news_id})">发表</button></div>`;
    h += '</div>'; document.getElementById('news-comments').innerHTML = h;
  });
}
function submitComment(nid) { const t = document.getElementById('comment-text').value.trim(); if (!t) return alert('请输入'); API.post('/api/news/' + nid + '/comments', { content: t }).then(r => { if (r.code === 200) loadNewsDetail(nid); else alert(r.msg); }); }
function resetNewsForm() { document.getElementById('news-edit-id').value = ''; document.getElementById('news-title').value = ''; document.getElementById('news-summary').value = ''; document.getElementById('news-content').value = ''; document.getElementById('news-form-title').textContent = '发布资讯'; }
function editNews(id) { API.get('/api/news/' + id).then(res => { if (res.code === 200) { const n = res.data; document.getElementById('news-edit-id').value = n.news_id; document.getElementById('news-title').value = n.title; document.getElementById('news-summary').value = n.summary || ''; document.getElementById('news-content').value = n.content || ''; document.getElementById('news-form-title').textContent = '编辑资讯'; showPage('news-create'); } }); }
function saveNews(e) { e.preventDefault(); const id = document.getElementById('news-edit-id').value; const d = { title: document.getElementById('news-title').value.trim(), summary: document.getElementById('news-summary').value.trim(), content: document.getElementById('news-content').value.trim(), status: 'published' }; if (!d.title || !d.content) return alert('标题和内容不能为空'); (id ? API.put('/api/news/' + id, d) : API.post('/api/news', d)).then(r => { if (r.code === 200) { alert(id ? '更新成功' : '发布成功'); resetNewsForm(); showPage('news'); } else alert(r.msg); }); }
function deleteNews(id) { if (confirm('确定删除？')) API.del('/api/news/' + id).then(r => { if (r.code === 200) { state.newsPage = 1; showPage('news'); } else alert(r.msg); }); }

// ============================================================
// 渠道
// ============================================================
function loadChannels() {
  API.get('/api/channels').then(res => {
    if (res.code !== 200) return;
    const adm = state.user && state.user.role === 'admin';
    document.getElementById('channels-tbody').innerHTML = (res.data || []).map(ch => `<tr><td>${ch.channel_id}</td><td>${ch.channel_name}</td><td>${ch.channel_type}</td><td><span class="status-badge ${ch.status === 1 ? 'status-active' : 'status-inactive'}">${ch.status === 1 ? '启用' : '停用'}</span></td><td class="action-btns">${adm ? `<button class="btn btn-sm btn-outline" onclick="editChannel(${ch.channel_id},'${esc(ch.channel_name)}','${esc(ch.channel_type)}')">编辑</button><button class="btn btn-sm btn-danger" onclick="deleteChannel(${ch.channel_id})">删除</button>` : ''}</td></tr>`).join('') || '<tr><td colspan="5" style="text-align:center;color:var(--text-muted)">暂无数据</td></tr>';
  });
}
function showChannelForm() { resetModal('channel', '新增渠道'); }
function editChannel(id, n, t) { resetModal('channel', '编辑渠道'); document.getElementById('ch-edit-id').value = id; document.getElementById('ch-name').value = n; document.getElementById('ch-type').value = t; }
function closeChannelModal() { document.getElementById('channel-modal').style.display = 'none'; }
function saveChannel(e) { e.preventDefault(); const id = document.getElementById('ch-edit-id').value; const d = { channel_name: document.getElementById('ch-name').value.trim(), channel_type: document.getElementById('ch-type').value.trim() }; if (!d.channel_name || !d.channel_type) return alert('不能为空'); (id ? API.put('/api/channels/' + id, d) : API.post('/api/channels', d)).then(r => { if (r.code === 200) { closeChannelModal(); loadChannels(); } else alert(r.msg); }); }
function deleteChannel(id) { if (confirm('确定删除？')) API.del('/api/channels/' + id).then(r => { if (r.code === 200) loadChannels(); else alert(r.msg); }); }

// ============================================================
// 统计
// ============================================================
function loadStats() {
  API.get('/api/stats/channel').then(res => {
    if (res.code !== 200) return;
    const d = res.data || [];
    const c1 = document.getElementById('chart-channel');
    if (c1) echarts.init(c1).setOption({ tooltip: { trigger: 'axis' }, legend: { data: ['浏览量', '曝光量'], textStyle: { color: '#4a4a4a' } }, xAxis: { type: 'category', data: d.map(x => x.channel_name), axisLabel: { rotate: 15, fontSize: 10 } }, yAxis: { type: 'value' }, color: ['#C41E3A', '#DAA520'], series: [{ name: '浏览量', type: 'bar', data: d.map(x => x.total_view) }, { name: '曝光量', type: 'bar', data: d.map(x => x.total_exposure) }], grid: { left: '3%', right: '4%', bottom: '15%', containLabel: true } });
    const c2 = document.getElementById('chart-channel-pie');
    if (c2) echarts.init(c2).setOption({ tooltip: { trigger: 'item' }, series: [{ type: 'pie', radius: ['45%', '75%'], data: d.map(x => ({ name: x.channel_name, value: x.total_view })), label: { fontSize: 10 }, itemStyle: { borderColor: '#fff', borderWidth: 2 } }] });
  });
  API.get('/api/stats/project').then(res => {
    if (res.code !== 200) return;
    const d = res.data || [];
    const c1 = document.getElementById('chart-project');
    if (c1) echarts.init(c1).setOption({ tooltip: { trigger: 'axis' }, legend: { data: ['浏览量', '曝光量'], textStyle: { color: '#4a4a4a' } }, xAxis: { type: 'category', data: d.map(x => x.project_name), axisLabel: { rotate: 15, fontSize: 10 } }, yAxis: { type: 'value' }, color: ['#4A7C59', '#6B9B7A'], series: [{ name: '浏览量', type: 'bar', data: d.map(x => x.total_view) }, { name: '曝光量', type: 'bar', data: d.map(x => x.total_exposure) }], grid: { left: '3%', right: '4%', bottom: '15%', containLabel: true } });
    const c2 = document.getElementById('chart-project-bar');
    if (c2) echarts.init(c2).setOption({ tooltip: { trigger: 'axis' }, xAxis: { type: 'category', data: d.map(x => x.project_name), axisLabel: { rotate: 15, fontSize: 10 } }, yAxis: { type: 'value' }, series: [{ type: 'bar', data: d.map(x => x.total_exposure), itemStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{ offset: 0, color: '#C41E3A' }, { offset: 1, color: '#DAA520' }]), borderRadius: [4, 4, 0, 0] }, label: { show: true, position: 'top', fontSize: 10 } }], grid: { left: '3%', right: '4%', bottom: '15%', top: '10%' } });
  });
  setTimeout(() => { ['chart-channel', 'chart-project', 'chart-channel-pie', 'chart-project-bar'].forEach(id => { const el = document.getElementById(id); if (el) { const i = echarts.getInstanceByDom(el); if (i) i.resize(); } }); }, 200);
}

// ============================================================
// 初始化
// ============================================================
document.addEventListener('DOMContentLoaded', () => {
  initSidebarUser();
  initPermissions();
  // 如果有跳转过来的目标页面
  const targetPage = localStorage.getItem('dashboard_page');
  localStorage.removeItem('dashboard_page');
  showPage(targetPage || 'categories');
});
