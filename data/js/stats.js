/**
 * 非遗文化传播数据统计模块
 * 成员D负责 - 调用后端统计接口，使用ECharts展示数据可视化图表
 * 注意：此文件由 frontend/index.html 通过 <script> 标签加载，
 *       依赖全局的 API 对象（在 app.js 中定义）
 */

// ============================================================
// 全局状态
// ============================================================
const StatsState = {
    channelData: [],
    projectData: [],
    charts: {},
};

// ============================================================
// 状态管理
// ============================================================
function updateStatus(isSuccess, msg) {
    return; // managed by frontend
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
    { channelId: 1, channelName: '官方网站', totalView: 22000, totalExposure: 63000 },
    { channelId: 2, channelName: '微信公众号', totalView: 15000, totalExposure: 40000 },
    { channelId: 3, channelName: '抖音短视频', totalView: 133000, totalExposure: 380000 },
    { channelId: 4, channelName: '线下博物馆', totalView: 3200, totalExposure: 8000 },
    { channelId: 5, channelName: '微博平台', totalView: 45000, totalExposure: 120000 },
    { channelId: 6, channelName: 'B站视频', totalView: 89000, totalExposure: 250000 }
];

const mockProjectData = [
    { projectId: 1, projectName: '景德镇手工制瓷技艺', totalView: 66200, totalExposure: 187000 },
    { projectId: 2, projectName: '昆曲', totalView: 15800, totalExposure: 46000 },
    { projectId: 3, projectName: '剪纸艺术', totalView: 42000, totalExposure: 115000 },
    { projectId: 4, projectName: '藏戏·格萨尔', totalView: 28500, totalExposure: 78000 },
    { projectId: 5, projectName: '敦煌壁画', totalView: 55000, totalExposure: 152000 },
    { projectId: 6, projectName: '古琴艺术', totalView: 18300, totalExposure: 52000 }
];

// ============================================================
// 加载数据
// ============================================================
async function loadChannelData() {
    const response = await API.get('/api/stats/channel');
    if (response.code === 200) {
        StatsState.channelData = response.data || [];
        renderChannelCharts();
        updateSummary();
        return true;
    }
    console.warn('后端接口未连接，使用模拟数据');
    StatsState.channelData = mockChannelData;
    renderChannelCharts();
    updateSummary();
    return true;
}

async function loadProjectData() {
    const response = await API.get('/api/stats/project');
    if (response.code === 200) {
        StatsState.projectData = response.data || [];
        renderProjectCharts();
        updateSummary();
        return true;
    }
    console.warn('后端接口未连接，使用模拟数据');
    StatsState.projectData = mockProjectData;
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
    const totalViews = StatsState.channelData.reduce((sum, item) => sum + (item.totalView || item.totalViews || 0), 0);
    const totalExposure = StatsState.channelData.reduce((sum, item) => sum + (item.totalExposure || 0), 0);

    document.getElementById('total-views').textContent = formatNumber(totalViews);
    document.getElementById('total-exposure').textContent = formatNumber(totalExposure);
    document.getElementById('channel-count').textContent = StatsState.channelData.length;
    document.getElementById('project-count').textContent = StatsState.projectData.length;
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
    const data = StatsState.channelData;

    // 渠道柱状图 - 浏览量和曝光量对比
    const channelChart = echarts.init(document.getElementById('chart-channel'));
    channelChart.setOption({
        tooltip: {
            trigger: 'axis',
            axisPointer: { type: 'shadow' },
            formatter: function (params) {
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
            data: data.map(item => item.channelName),
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
                formatter: function (value) {
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
                data: data.map(item => item.totalView || item.totalViews || 0),
                itemStyle: { borderRadius: [4, 4, 0, 0] }
            },
            {
                name: '曝光量',
                type: 'bar',
                barWidth: '35%',
                data: data.map(item => item.totalExposure || 0),
                itemStyle: { borderRadius: [4, 4, 0, 0] }
            }
        ]
    });
    StatsState.charts['channel'] = channelChart;

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
                    value: item.totalView || item.totalViews || 0,
                    name: item.channelName,
                    itemStyle: {
                        color: getChannelColor(index)
                    }
                }))
            }
        ]
    });
    StatsState.charts['channel-pie'] = pieChart;
}

// ============================================================
// 渲染图表 - 项目相关
// ============================================================
function renderProjectCharts() {
    const data = StatsState.projectData;

    // 项目柱状图 - 浏览量和曝光量对比
    const projectChart = echarts.init(document.getElementById('chart-project'));
    projectChart.setOption({
        tooltip: {
            trigger: 'axis',
            axisPointer: { type: 'shadow' },
            formatter: function (params) {
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
            data: data.map(item => item.projectName),
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
                formatter: function (value) {
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
                data: data.map(item => item.totalView || item.totalViews || 0),
                itemStyle: { borderRadius: [4, 4, 0, 0] }
            },
            {
                name: '曝光量',
                type: 'bar',
                barWidth: '35%',
                data: data.map(item => item.totalExposure || 0),
                itemStyle: { borderRadius: [4, 4, 0, 0] }
            }
        ]
    });
    StatsState.charts['project'] = projectChart;

    // 项目曝光量排行 - 水平条形图
    const barChart = echarts.init(document.getElementById('chart-project-bar'));
    const sortedData = [...data].sort((a, b) =>
        (b.totalExposure || 0) - (a.totalExposure || 0)
    );

    barChart.setOption({
        tooltip: {
            trigger: 'axis',
            axisPointer: { type: 'shadow' },
            formatter: function (params) {
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
                formatter: function (value) {
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
            data: sortedData.map(item => item.projectName),
            axisLabel: {
                fontSize: 11,
                color: '#4a4a4a'
            },
            axisLine: { lineStyle: { color: '#ddd' } }
        },
        series: [
            {
                type: 'bar',
                data: sortedData.map(item => item.totalExposure || 0),
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
                    formatter: function (params) {
                        return formatNumber(params.value);
                    }
                }
            }
        ]
    });
    StatsState.charts['project-bar'] = barChart;
}

// ============================================================
// 渲染综合分析图表
// ============================================================
function renderCombinedChart() {
    const channelData = StatsState.channelData;
    const projectData = StatsState.projectData;

    if (channelData.length === 0 && projectData.length === 0) {
        document.getElementById('chart-combined').innerHTML =
            '<div class="loading">暂无数据</div>';
        return;
    }

    const chart = echarts.init(document.getElementById('chart-combined'));

    // 准备数据：取前5个渠道和前5个项目
    const topChannels = [...channelData].sort((a, b) =>
        (b.totalView || b.totalViews || 0) - (a.totalView || a.totalViews || 0)
    ).slice(0, 5);

    const topProjects = [...projectData].sort((a, b) =>
        (b.totalView || b.totalViews || 0) - (a.totalView || a.totalViews || 0)
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
                data: topChannels.map(item => item.channelName),
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
                    formatter: function (value) {
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
                    formatter: function (value) {
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
                data: topChannels.map(item => item.totalView || item.totalViews || 0),
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
                data: topProjects.map(item => item.totalView || item.totalViews || 0),
                smooth: true,
                lineStyle: { color: '#4A7C59', width: 3 },
                itemStyle: { color: '#4A7C59' },
                symbol: 'circle',
                symbolSize: 8
            }
        ]
    };

    chart.setOption(option);
    StatsState.charts['combined'] = chart;
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
    Object.values(StatsState.charts).forEach(chart => {
        if (chart && typeof chart.resize === 'function') {
            chart.resize();
        }
    });
}

// ============================================================
// 初始化：由 app.js 的 showPage('stats') → loadStats() 触发
// ============================================================
window.addEventListener('resize', handleResize);