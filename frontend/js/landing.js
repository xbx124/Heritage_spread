/**
 * 非遗文化数字化传播系统 - 首页逻辑
 * 负责轮播、数据加载、登录注册弹窗
 */

// ============================================================
// API
// ============================================================
const API = {
    async request(method, url, data) {
        const headers = { 'Content-Type': 'application/json' };
        const opts = { method, headers };
        if (data) opts.body = JSON.stringify(data);
        const res = await fetch(url, opts);
        return res.json();
    },
    get(url) { return this.request('GET', url); },
    post(url, data) { return this.request('POST', url, data); },
};

// ============================================================
// 轮播
// ============================================================
let carouselIndex = 0;
let carouselTimer = null;

function initCarousel() {
    const slides = document.querySelectorAll('.hero-slide');
    const dots = document.querySelectorAll('.hero-dots .dot');
    const total = slides.length;

    function goTo(index) {
        slides.forEach(s => s.classList.remove('active'));
        dots.forEach(d => d.classList.remove('active'));
        carouselIndex = index;
        slides[index].classList.add('active');
        dots[index].classList.add('active');
    }
    function next() { goTo((carouselIndex + 1) % total); }
    function reset() { clearInterval(carouselTimer); carouselTimer = setInterval(next, 5000); }

    dots.forEach(d => {
        d.addEventListener('click', function () {
            goTo(parseInt(this.getAttribute('data-index')));
            reset();
        });
    });

    let touchX = 0;
    document.getElementById('hero').addEventListener('touchstart', e => { touchX = e.touches[0].clientX; });
    document.getElementById('hero').addEventListener('touchend', e => {
        const diff = touchX - e.changedTouches[0].clientX;
        if (Math.abs(diff) > 60) {
            goTo(diff > 0 ? (carouselIndex + 1) % total : (carouselIndex - 1 + total) % total);
            reset();
        }
    });

    carouselTimer = setInterval(next, 5000);
}



// ============================================================
// 弹窗
// ============================================================
function openModal(type) {
    document.getElementById('modal-' + type).style.display = 'flex';
}

function closeModal(type) {
    document.getElementById('modal-' + type).style.display = 'none';
}

function switchAuth(type) {
    closeModal('login');
    closeModal('register');
    openModal(type);
}

// ============================================================
// 认证
// ============================================================
function doLogin(e) {
    e.preventDefault();
    const u = document.getElementById('login-username').value.trim();
    const p = document.getElementById('login-password').value.trim();
    if (!u || !p) return alert('请输入用户名和密码');
    API.post('/api/auth/login', { username: u, password: p }).then(res => {
        if (res.code === 200) {
            localStorage.setItem('token', res.data.token);
            localStorage.setItem('user', JSON.stringify(res.data.user));
            window.location.href = '/index.html';
        } else {
            alert(res.msg || '登录失败');
        }
    });
}

function doRegister(e) {
    e.preventDefault();
    const u = document.getElementById('reg-username').value.trim();
    const p = document.getElementById('reg-password').value.trim();
    const pc = document.getElementById('reg-password-confirm').value.trim();
    if (!u || !p || !pc) return alert('请填写所有字段');
    if (p !== pc) return alert('两次输入的密码不一致');
    API.post('/api/auth/register', { username: u, password: p }).then(res => {
        if (res.code === 200) {
            alert('注册成功，请登录');
            closeModal('register');
            openModal('login');
            document.getElementById('login-username').value = u;
        } else {
            alert(res.msg || '注册失败');
        }
    });
}

document.addEventListener('DOMContentLoaded', () => {
    initCarousel();
});
