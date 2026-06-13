/**
 * 非遗文化传播数据统计模块
 * 成员D负责 - 调用后端统计接口，使用ECharts展示数据可视化图表
 */

// ============================================================
// API配置
// ============================================================
const API_BASE = 'http://localhost:8080/api';

const API = {
    async request(method, url, data) {
        const headers = { 'Content-Type': 'application/json' };
        const options = { method, headers };
        if (data && method !== 'GET') {
            options.body = JSON.stringify(data);
        }
        try {
            const response = await fetch(url, options);
            return await response.json();
        } catch (error) {
            console.error('API请求失败:', error);
            return { code: 500, msg: '网络请求失败', data: null };
        }
    },
    get(url) { return this.request('GET', url); },
    post(url, data) { return this.request('POST', url, data); },
};

// ============================================================
// 全局状态
// ============================================================
const state = {
    channelData: [],
    projectData: [],
    charts: {},
};

// ============================================================
// 状态管理
// ============================================================
function updateStatus(isSuccess, msg) {
    const el = document.getElementById('api-status');
    if (isSuccess) {
        el.className = 'api-status';
        el.textContent = msg || '✓ 数据同步中';
    } else {
        el.className = 'api-status error';
        el.textContent = msg || '✗ 连接失败';
    }
}

// ============================================================
// 模拟数据（用于预览效果）
// ============================================================
const mockChannelData = [
    { channel_id: 1, channel_name: '官方网站', total_view: 22000, total_exposure: 63000 },
    { channel_id: 2, channel_name: '微信公众号', total_view: 15000, total_exposure: 40000 },
    { channel_id: 3, channel_name: '抖音短视频', total_view: 133000, total_exposure: 380000 },
    { channel_id: 4, channel_name: '线下博物馆', total_view: 3200, total_exposure: 8000 },
    { channel_id: 5, channel_name: '微博平台', total_view: 45000, total_exposure: 120000 },
    { channel_id: 6, channel_name: 'B站视频', total_view: 89000, total_exposure: 250000 }
];

const mockProjectData = [
    { project_id: 1, project_name: '景德镇手工制瓷技艺', total_view: 66200, total_exposure: 187000 },
    { project_id: 2, project_name: '昆曲', total_view: 15800, total_exposure: 46000 },
    { project_id: 3, project_name: '剪纸艺术', total_view: 42000, total_exposure: 115000 },
    { project_id: 4, project_name: '藏戏·格萨尔', total_view: 28500, total_exposure: 78000 },
    { project_id: 5, project_name: '敦煌壁画', total_view: 55000, total_exposure: 152000 },
    { project_id: 6, project_name: '古琴艺术', total_view: 18300, total_exposure: 52000 }
];

// ============================================================
// 加载数据
// ============================================================
async function loadChannelData() {
    const response = await API.get(`${API_BASE}/stats/channel`);
    if (response.code === 200) {
        state.channelData = response.data || [];
        renderChannelCharts();
        updateSummary();
        return true;
    }
    console.warn('后端接口未连接，使用模拟数据');
    state.channelData = mockChannelData;
    renderChannelCharts();
    updateSummary();
    return true;
}

async function loadProjectData() {
    const response = await API.get(`${API_BASE}/stats/project`);
    if (response.code === 200) {
        state.projectData = response.data || [];
        renderProjectCharts();
        updateSummary();
        return true;
    }
    console.warn('后端接口未连接，使用模拟数据');
    state.projectData = mockProjectData;
    renderProjectCharts();
    updateSummary();
    return true;
}

async function loadAllData() {
    updateStatus(true, '✓ 数据同步中...');
    
    const [channelOk, projectOk] = await Promise.all([
        loadChannelData(),
        loadProjectData()
    ]);
    
    if (channelOk && projectOk) {
        renderCombinedChart();
        updateStatus(true, '✓ 数据已更新（模拟数据）');
    } else {
        updateStatus(false, '✗ 部分数据加载失败');
    }
}

// ============================================================
// 更新汇总数据
// ============================================================
function updateSummary() {
    const totalViews = state.channelData.reduce((sum, item) => sum + (item.total_view || item.total_views || 0), 0);
    const totalExposure = state.channelData.reduce((sum, item) => sum + (item.total_exposure || 0), 0);
    
    document.getElementById('total-views').textContent = formatNumber(totalViews);
    document.getElementById('total-exposure').textContent = formatNumber(totalExposure);
    document.getElementById('channel-count').textContent = state.channelData.length;
    document.getElementById('project-count').textContent = state.projectData.length;
}

function formatNumber(num) {
    if (num >= 10000) {
        return (num / 10000).toFixed(1) + '万';
    }
    return num.toLocaleString();
}

// ============================================================
// 渲染图表 - 渠道相关
// ============================================================
function renderChannelCharts() {
    const data = state.channelData;
    
    // 渠道柱状图 - 浏览量和曝光量对比
    const channelChart = echarts.init(document.getElementById('chart-channel'));
    channelChart.setOption({
        tooltip: {
            trigger: 'axis',
            axisPointer: { type: 'shadow' },
            formatter: function(params) {
                let result = params[0].name + '<br/>';
                params.forEach(item => {
                    result += `${item.marker} ${item.seriesName}: ${formatNumber(item.value)}<br/>`;
                });
                return result;
            }
        },
        legend: {
            data: ['浏览量', '曝光量'],
            textStyle: { color: '#4a4a4a', fontSize: 12 }
        },
        grid: {
            left: '3%',
            right: '4%',
            bottom: '12%',
            top: '12%',
            containLabel: true
        },
        xAxis: {
            type: 'category',
            data: data.map(item => item.channel_name),
            axisLabel: {
                rotate: 20,
                fontSize: 11,
                color: '#666'
            },
            axisLine: { lineStyle: { color: '#ddd' } }
        },
        yAxis: {
            type: 'value',
            axisLabel: {
                formatter: function(value) {
                    if (value >= 10000) {
                        return (value / 10000) + '万';
                    }
                    return value;
                },
                color: '#666'
            },
            splitLine: { lineStyle: { color: '#eee' } }
        },
        color: ['#C41E3A', '#DAA520'],
        series: [
            {
                name: '浏览量',
                type: 'bar',
                barWidth: '35%',
                data: data.map(item => item.total_view || item.total_views || 0),
                itemStyle: { borderRadius: [4, 4, 0, 0] }
            },
            {
                name: '曝光量',
                type: 'bar',
                barWidth: '35%',
                data: data.map(item => item.total_exposure || 0),
                itemStyle: { borderRadius: [4, 4, 0, 0] }
            }
        ]
    });
    state.charts['channel'] = channelChart;

    // 渠道饼图 - 浏览量分布
    const pieChart = echarts.init(document.getElementById('chart-channel-pie'));
    pieChart.setOption({
        tooltip: {
            trigger: 'item',
            formatter: '{b}: {c} ({d}%)'
        },
        legend: {
            orient: 'vertical',
            right: '5%',
            top: 'center',
            textStyle: { fontSize: 11, color: '#666' }
        },
        series: [
            {
                type: 'pie',
                radius: ['45%', '75%'],
                center: ['40%', '50%'],
                avoidLabelOverlap: false,
                itemStyle: {
                    borderRadius: 6,
                    borderColor: '#fff',
                    borderWidth: 2
                },
                label: {
                    show: false,
                    position: 'center'
                },
                emphasis: {
                    label: {
                        show: true,
                        fontSize: 14,
                        fontWeight: 'bold'
                    }
                },
                labelLine: { show: false },
                data: data.map((item, index) => ({
                    value: item.total_view || item.total_views || 0,
                    name: item.channel_name,
                    itemStyle: {
                        color: getChannelColor(index)
                    }
                }))
            }
        ]
    });
    state.charts['channel-pie'] = pieChart;
}

// ============================================================
// 渲染图表 - 项目相关
// ============================================================
function renderProjectCharts() {
    const data = state.projectData;

    // 项目柱状图 - 浏览量和曝光量对比
    const projectChart = echarts.init(document.getElementById('chart-project'));
    projectChart.setOption({
        tooltip: {
            trigger: 'axis',
            axisPointer: { type: 'shadow' },
            formatter: function(params) {
                let result = params[0].name + '<br/>';
                params.forEach(item => {
                    result += `${item.marker} ${item.seriesName}: ${formatNumber(item.value)}<br/>`;
                });
                return result;
            }
        },
        legend: {
            data: ['浏览量', '曝光量'],
            textStyle: { color: '#4a4a4a', fontSize: 12 }
        },
        grid: {
            left: '3%',
            right: '4%',
            bottom: '12%',
            top: '12%',
            containLabel: true
        },
        xAxis: {
            type: 'category',
            data: data.map(item => item.project_name),
            axisLabel: {
                rotate: 20,
                fontSize: 11,
                color: '#666'
            },
            axisLine: { lineStyle: { color: '#ddd' } }
        },
        yAxis: {
            type: 'value',
            axisLabel: {
                formatter: function(value) {
                    if (value >= 10000) {
                        return (value / 10000) + '万';
                    }
                    return value;
                },
                color: '#666'
            },
            splitLine: { lineStyle: { color: '#eee' } }
        },
        color: ['#4A7C59', '#6B9B7A'],
        series: [
            {
                name: '浏览量',
                type: 'bar',
                barWidth: '35%',
                data: data.map(item => item.total_view || item.total_views || 0),
                itemStyle: { borderRadius: [4, 4, 0, 0] }
            },
            {
                name: '曝光量',
                type: 'bar',
                barWidth: '35%',
                data: data.map(item => item.total_exposure || 0),
                itemStyle: { borderRadius: [4, 4, 0, 0] }
            }
        ]
    });
    state.charts['project'] = projectChart;

    // 项目曝光量排行 - 水平条形图
    const barChart = echarts.init(document.getElementById('chart-project-bar'));
    const sortedData = [...data].sort((a, b) => 
        (b.total_exposure || 0) - (a.total_exposure || 0)
    );
    
    barChart.setOption({
        tooltip: {
            trigger: 'axis',
            axisPointer: { type: 'shadow' },
            formatter: function(params) {
                const item = params[0];
                return `${item.name}<br/>${item.marker} 曝光量: ${formatNumber(item.value)}`;
            }
        },
        grid: {
            left: '25%',
            right: '8%',
            bottom: '10%',
            top: '10%',
            containLabel: true
        },
        xAxis: {
            type: 'value',
            axisLabel: {
                formatter: function(value) {
                    if (value >= 10000) {
                        return (value / 10000) + '万';
                    }
                    return value;
                },
                color: '#666'
            },
            splitLine: { lineStyle: { color: '#eee' } }
        },
        yAxis: {
            type: 'category',
            data: sortedData.map(item => item.project_name),
            axisLabel: {
                fontSize: 11,
                color: '#4a4a4a'
            },
            axisLine: { lineStyle: { color: '#ddd' } }
        },
        series: [
            {
                type: 'bar',
                data: sortedData.map(item => item.total_exposure || 0),
                itemStyle: {
                    color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
                        { offset: 0, color: '#C41E3A' },
                        { offset: 1, color: '#DAA520' }
                    ]),
                    borderRadius: [0, 4, 4, 0]
                },
                label: {
                    show: true,
                    position: 'right',
                    fontSize: 11,
                    formatter: function(params) {
                        return formatNumber(params.value);
                    }
                }
            }
        ]
    });
    state.charts['project-bar'] = barChart;
}

// ============================================================
// 渲染综合分析图表
// ============================================================
function renderCombinedChart() {
    const channelData = state.channelData;
    const projectData = state.projectData;

    if (channelData.length === 0 && projectData.length === 0) {
        document.getElementById('chart-combined').innerHTML = 
            '<div class="loading">暂无数据</div>';
        return;
    }

    const chart = echarts.init(document.getElementById('chart-combined'));
    
    // 准备数据：取前5个渠道和前5个项目
    const topChannels = [...channelData].sort((a, b) => 
        (b.total_view || b.total_views || 0) - (a.total_view || a.total_views || 0)
    ).slice(0, 5);
    
    const topProjects = [...projectData].sort((a, b) => 
        (b.total_view || b.total_views || 0) - (a.total_view || a.total_views || 0)
    ).slice(0, 5);

    const option = {
        tooltip: {
            trigger: 'axis',
            axisPointer: { type: 'cross', crossStyle: { color: '#999' } }
        },
        legend: {
            data: ['渠道浏览量', '项目浏览量'],
            textStyle: { color: '#4a4a4a', fontSize: 12 }
        },
        grid: {
            left: '3%',
            right: '4%',
            bottom: '8%',
            top: '15%',
            containLabel: true
        },
        xAxis: [
            {
                type: 'category',
                data: topChannels.map(item => item.channel_name),
                axisPointer: { type: 'shadow' },
                axisLabel: {
                    rotate: 15,
                    fontSize: 11,
                    color: '#666'
                },
                axisLine: { lineStyle: { color: '#ddd' } }
            }
        ],
        yAxis: [
            {
                type: 'value',
                name: '浏览量',
                nameTextStyle: { color: '#666', fontSize: 12 },
                axisLabel: {
                    formatter: function(value) {
                        if (value >= 10000) return (value / 10000) + '万';
                        return value;
                    },
                    color: '#666'
                },
                splitLine: { lineStyle: { color: '#eee' } }
            },
            {
                type: 'value',
                name: '项目浏览量',
                nameTextStyle: { color: '#666', fontSize: 12 },
                axisLabel: {
                    formatter: function(value) {
                        if (value >= 10000) return (value / 10000) + '万';
                        return value;
                    },
                    color: '#666'
                },
                splitLine: { show: false }
            }
        ],
        series: [
            {
                name: '渠道浏览量',
                type: 'bar',
                barWidth: '40%',
                data: topChannels.map(item => item.total_view || item.total_views || 0),
                itemStyle: {
                    color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                        { offset: 0, color: '#C41E3A' },
                        { offset: 1, color: '#8B0000' }
                    ]),
                    borderRadius: [4, 4, 0, 0]
                }
            },
            {
                name: '项目浏览量',
                type: 'line',
                yAxisIndex: 1,
                data: topProjects.map(item => item.total_view || item.total_views || 0),
                smooth: true,
                lineStyle: { color: '#4A7C59', width: 3 },
                itemStyle: { color: '#4A7C59' },
                symbol: 'circle',
                symbolSize: 8
            }
        ]
    };

    chart.setOption(option);
    state.charts['combined'] = chart;
}

// ============================================================
// 辅助函数
// ============================================================
function getChannelColor(index) {
    const colors = [
        '#C41E3A', '#DAA520', '#4A7C59', '#1E90FF', '#9370DB',
        '#FF6347', '#00CED1', '#FFD700', '#FF69B4', '#3CB371'
    ];
    return colors[index % colors.length];
}

// ============================================================
// 响应式处理
// ============================================================
function handleResize() {
    Object.values(state.charts).forEach(chart => {
        if (chart && typeof chart.resize === 'function') {
            chart.resize();
        }
    });
}

// ============================================================
// 初始化
// ============================================================
document.addEventListener('DOMContentLoaded', () => {
    loadAllData();
    window.addEventListener('resize', handleResize);
});