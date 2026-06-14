"""
非遗文化数字化传播系统 - 前端服务 + API反向代理
Flask 负责静态文件服务，所有 /api/* 请求转发至 Java Spring Boot 后端
"""

import os
import requests as http
from flask import Flask, request, send_from_directory, Response

# ============================================================
# 配置
# ============================================================
JAVA_BACKEND = "http://localhost:8081"   # Java Spring Boot 后端地址

app = Flask(__name__, static_folder='frontend', static_url_path='')

# ============================================================
# 静态文件服务
# ============================================================

@app.route('/')
def index():
    return send_from_directory('frontend', 'login.html')


@app.route('/<path:path>')
def static_files(path):
    # data 目录（统计模块 JS）
    if os.path.isfile(os.path.join('data', path)):
        return send_from_directory('data', path)
    # frontend 目录
    if os.path.isfile(os.path.join('frontend', path)):
        return send_from_directory('frontend', path)
    # 默认返回 index.html（SPA fallback）
    return send_from_directory('frontend', 'index.html')


# ============================================================
# API 反向代理 → Java 后端
# ============================================================

FORWARD_HEADERS = [
    "Authorization", "Content-Type", "Accept",
    "Origin", "Referer", "User-Agent",
]

@app.route('/api/<path:subpath>', methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH'])
def proxy_api(subpath):
    """将所有 /api/* 请求原样转发到 Java 后端"""
    target_url = f"{JAVA_BACKEND}/api/{subpath}"

    # 转发请求头
    headers = {}
    for key in FORWARD_HEADERS:
        value = request.headers.get(key)
        if value:
            headers[key] = value

    # 转发请求体（JSON）
    body = request.get_data()

    try:
        resp = http.request(
            method=request.method,
            url=target_url,
            headers=headers,
            data=body,
            params=request.args,
            timeout=30,
        )
        # 返回 Java 后端的原始响应
        return Response(
            resp.content,
            status=resp.status_code,
            headers={"Content-Type": resp.headers.get("Content-Type", "application/json")},
        )
    except http.exceptions.ConnectionError:
        return {
            "code": 503,
            "msg": f"后端服务未启动（{JAVA_BACKEND}），请先启动 Java Spring Boot 服务",
            "data": None,
        }, 503
    except Exception as e:
        return {
            "code": 500,
            "msg": f"代理请求失败: {str(e)}",
            "data": None,
        }, 500


# ============================================================
# 启动
# ============================================================
if __name__ == '__main__':
    print("=" * 60)
    print("  非遗文化数字化传播系统 - 前端服务")
    print(f"  静态文件: http://localhost:8080")
    print(f"  API 代理: /api/* → {JAVA_BACKEND}/api/*")
    print("=" * 60)
    print("  请确保 Java 后端已启动（端口 8081）")
    print("  测试账号由 Java 后端管理")
    print("=" * 60)
    app.run(host='0.0.0.0', port=8080, debug=True)
