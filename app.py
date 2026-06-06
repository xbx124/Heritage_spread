"""
非遗文化数字化传播系统 - 后端服务 (Mock版本)
所有接口返回mock数据，无需连接数据库
"""

import json
import random
import time
import hashlib
import base64
from datetime import datetime, timedelta
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os

app = Flask(__name__, static_folder='frontend', static_url_path='')
CORS(app)

# ============================================================
# Mock 数据
# ============================================================

users = [
    {"user_id": 1, "username": "admin", "password": "123456", "role": "admin", "create_time": "2025-04-01 10:00:00"},
    {"user_id": 2, "username": "editor1", "password": "123456", "role": "editor", "create_time": "2025-04-02 10:00:00"},
    {"user_id": 3, "username": "user1", "password": "123456", "role": "user", "create_time": "2025-04-03 10:00:00"},
]

categories = [
    {"category_id": 1, "category_name": "传统技艺", "category_desc": "包括各类手工技艺、制作工艺等"},
    {"category_id": 2, "category_name": "传统戏剧", "category_desc": "包括地方戏曲、皮影戏等表演艺术"},
    {"category_id": 3, "category_name": "传统民俗", "category_desc": "包括节庆习俗、礼仪风俗等"},
    {"category_id": 4, "category_name": "民间文学", "category_desc": "包括神话、传说、史诗、故事等"},
]

projects = [
    {"project_id": 1, "project_name": "景德镇手工制瓷技艺", "category_id": 1, "category_name": "传统技艺",
     "area": "江西景德镇", "project_intro": "千年瓷都景德镇独有的手工拉坯、绘瓷技艺，列入国家级非遗名录。景德镇手工制瓷技艺始于汉代，兴于宋代，盛于明清。其核心工艺包括拉坯、利坯、画坯、施釉和烧窑等环节，每一道工序都凝结着匠人的智慧与心血。青花、粉彩、颜色釉等装饰技法更是举世闻名。",
     "create_time": "2025-05-01 10:00:00"},
    {"project_id": 2, "project_name": "昆曲", "category_id": 2, "category_name": "传统戏剧",
     "area": "江苏苏州", "project_intro": "中国现存最古老的戏曲剧种之一，被誉为\"百戏之祖\"。昆曲发源于元末明初的苏州昆山一带，距今已有六百余年历史。其唱腔婉转细腻，表演载歌载舞，是中国戏曲艺术的瑰宝。2001年被联合国教科文组织列为\"人类口头和非物质遗产代表作\"。",
     "create_time": "2025-05-02 10:00:00"},
    {"project_id": 3, "project_name": "春节（春节习俗）", "category_id": 3, "category_name": "传统民俗",
     "area": "全国", "project_intro": "中华民族最重要的传统节日，包含守岁、放鞭炮、拜年等习俗。春节蕴含着中华民族深厚的历史文化积淀，是中国人情感凝聚和文化认同的重要载体。",
     "create_time": "2025-05-03 10:00:00"},
    {"project_id": 4, "project_name": "格萨尔", "category_id": 4, "category_name": "民间文学",
     "area": "西藏、青海", "project_intro": "藏族英雄史诗，世界最长史诗之一，口耳相传至今。《格萨尔》是研究古代藏族社会历史、宗教信仰、民俗风情的重要文献，被誉为东方的《荷马史诗》。",
     "create_time": "2025-05-04 10:00:00"},
    {"project_id": 5, "project_name": "蜀绣", "category_id": 1, "category_name": "传统技艺",
     "area": "四川成都", "project_intro": "又称川绣，中国四大名绣之一，起源于川西民间，历史悠久。蜀绣以软缎和彩丝为主要原料，针法多达百余种。",
     "create_time": "2025-05-05 10:00:00"},
    {"project_id": 6, "project_name": "越剧", "category_id": 2, "category_name": "传统戏剧",
     "area": "浙江绍兴", "project_intro": "中国第二大剧种，发源于浙江嵊州，被誉为\"流传最广的地方剧种\"。越剧长于抒情，以唱为主，声音优美动听。",
     "create_time": "2025-05-06 10:00:00"},
    {"project_id": 7, "project_name": "端午节", "category_id": 3, "category_name": "传统民俗",
     "area": "全国", "project_intro": "每年农历五月初五，是集拜神祭祖、祈福辟邪、欢庆娱乐和饮食为一体的民俗大节。2009年入选人类非物质文化遗产代表作名录。",
     "create_time": "2025-05-07 10:00:00"},
    {"project_id": 8, "project_name": "玛纳斯", "category_id": 4, "category_name": "民间文学",
     "area": "新疆克孜勒苏", "project_intro": "柯尔克孜族英雄史诗，中国三大史诗之一，歌颂了英雄玛纳斯及其子孙八代人的传奇故事。",
     "create_time": "2025-05-08 10:00:00"},
]

inheritors = [
    {"inheritor_id": 1, "name": "王龙根", "project_id": 1, "project_name": "景德镇手工制瓷技艺",
     "years": 40, "intro": "景德镇手工拉坯第四代传承人，师从其父，精通青花与粉彩。从业四十年来潜心钻研，作品屡获国内外大奖。",
     "avatar": None},
    {"inheritor_id": 2, "name": "汪世瑜", "project_id": 2, "project_name": "昆曲",
     "years": 50, "intro": "著名昆曲表演艺术家，国家级非遗传承人，工小生。其嗓音清亮圆润，表演细腻传神，为当代昆曲界领军人物。",
     "avatar": None},
    {"inheritor_id": 3, "name": "才让旦周", "project_id": 4, "project_name": "格萨尔",
     "years": 35, "intro": "格萨尔说唱艺人，能完整演唱百余部史诗。从小耳濡目染，熟谙格萨尔史诗的各类唱腔与曲调。",
     "avatar": None},
    {"inheritor_id": 4, "name": "李淑芬", "project_id": 5, "project_name": "蜀绣",
     "years": 30, "intro": "蜀绣技艺传承人，擅长双面绣与异色绣，作品曾作为国礼赠送外国元首。",
     "avatar": None},
    {"inheritor_id": 5, "name": "陈月华", "project_id": 6, "project_name": "越剧",
     "years": 45, "intro": "越剧尹派传人，扮相俊美，唱腔醇厚，被誉为\"江南第一小生\"。",
     "avatar": None},
]

news_list = [
    {"news_id": 1, "title": "昆曲进校园活动正式启动", "content": "<p>近日，由文化和旅游部主办的'昆曲进校园'系列活动在全国多所高校正式拉开帷幕。活动旨在让更多年轻学子近距离感受昆曲艺术的魅力，推动传统戏曲文化的传承与发展。</p><p>活动期间，汪世瑜等著名昆曲表演艺术家将走进校园，通过讲演结合的方式，向学生们介绍昆曲的历史渊源、艺术特色和鉴赏方法。此外，还将设置互动体验环节，让同学们亲身体验昆曲的唱腔和身段表演。</p>",
     "summary": "活动旨在让更多年轻学子近距离感受昆曲艺术的魅力。", "user_id": 2, "author": "editor1",
     "publish_time": "2025-05-10 09:00:00", "status": "published"},
    {"news_id": 2, "title": "景德镇国际陶瓷博览会圆满落幕", "content": "<p>第20届景德镇国际陶瓷博览会于近日圆满落幕。本届博览会吸引了来自30多个国家和地区的500余家陶瓷企业和艺术家参展，累计参观人数突破20万人次。</p><p>博览会期间，景德镇手工制瓷技艺传承人王龙根进行了现场制瓷表演，精湛的技艺赢得了国内外观众的高度赞誉。多件非遗传承人作品在拍卖会上以高价成交，充分体现了非遗文化的市场价值。</p>",
     "summary": "第20届景德镇国际陶瓷博览会圆满落幕，吸引众多国际参展商。", "user_id": 2, "author": "editor1",
     "publish_time": "2025-05-15 14:00:00", "status": "published"},
    {"news_id": 3, "title": "数字化助力非遗保护：新春特别策划", "content": "<p>随着数字化技术的飞速发展，越来越多的非遗项目开始借助数字手段进行记录、保存和传播。从3D扫描到VR展示，从短视频传播到在线教学，数字化正在为传统文化注入新的活力。</p><p>春节期间，本平台将推出\"春节非遗文化特辑\"，通过图文、视频、直播等多种形式，向公众展示各地丰富多彩的春节非遗习俗，让传统文化在数字时代焕发新的生机。</p>",
     "summary": "数字化技术越来越多地应用于非遗保护与传播中。", "user_id": 2, "author": "editor1",
     "publish_time": "2025-05-20 10:00:00", "status": "published"},
    {"news_id": 4, "title": "格萨尔史诗国际学术研讨会召开", "content": "<p>2025年国际格萨尔史诗学术研讨会在拉萨隆重召开，来自中国、蒙古、俄罗斯、印度等国家的专家学者齐聚一堂，共同探讨格萨尔史诗的保护与传承。</p><p>才让旦周等说唱艺人在会上进行了精彩的说唱表演，生动展现了格萨尔史诗的独特魅力和丰富的文化内涵。与会专家一致认为，应进一步加强格萨尔史诗的数字化保护工作。</p>",
     "summary": "国际学者齐聚拉萨，共商格萨尔史诗保护大计。", "user_id": 2, "author": "editor1",
     "publish_time": "2025-05-25 16:00:00", "status": "published"},
    {"news_id": 5, "title": "蜀绣技艺培训班面向社会招生", "content": "<p>为传承和推广蜀绣技艺，四川省非遗保护中心联合成都市文化馆开办的蜀绣技艺培训班现面向社会公开招生。培训班由国家级非遗传承人李淑芬亲自授课。</p><p>课程内容包括蜀绣基础知识、基本针法训练、简单图案刺绣实践等，学期三个月，每周六授课。欢迎对蜀绣感兴趣的朋友踊跃报名。</p>",
     "summary": "国家级非遗传承人李淑芬亲自授课，欢迎报名。", "user_id": 2, "author": "editor1",
     "publish_time": "2025-06-01 08:00:00", "status": "published"},
]

channels = [
    {"channel_id": 1, "channel_name": "官方网站", "channel_type": "线上-网站", "status": 1},
    {"channel_id": 2, "channel_name": "微信公众号", "channel_type": "线上-社交", "status": 1},
    {"channel_id": 3, "channel_name": "抖音短视频", "channel_type": "线上-短视频", "status": 1},
    {"channel_id": 4, "channel_name": "线下博物馆展", "channel_type": "线下-展览", "status": 1},
    {"channel_id": 5, "channel_name": "B站频道", "channel_type": "线上-视频", "status": 1},
]

stats_channel = [
    {"channel_id": 1, "channel_name": "官方网站", "total_view": 22000, "total_exposure": 63000},
    {"channel_id": 2, "channel_name": "微信公众号", "total_view": 15000, "total_exposure": 40000},
    {"channel_id": 3, "channel_name": "抖音短视频", "total_view": 133000, "total_exposure": 380000},
    {"channel_id": 4, "channel_name": "线下博物馆展", "total_view": 3200, "total_exposure": 8000},
    {"channel_id": 5, "channel_name": "B站频道", "total_view": 18000, "total_exposure": 55000},
]

stats_project = [
    {"project_id": 1, "project_name": "景德镇手工制瓷技艺", "total_view": 66200, "total_exposure": 187000},
    {"project_id": 2, "project_name": "昆曲", "total_view": 15800, "total_exposure": 46000},
    {"project_id": 3, "project_name": "春节（春节习俗）", "total_view": 91200, "total_exposure": 258000},
    {"project_id": 4, "project_name": "格萨尔", "total_view": 4100, "total_exposure": 11000},
    {"project_id": 5, "project_name": "蜀绣", "total_view": 23000, "total_exposure": 65000},
    {"project_id": 6, "project_name": "越剧", "total_view": 18000, "total_exposure": 52000},
]

trend_data = {
    1: [
        {"date": "2025-05-01", "view_num": 1200, "exposure_num": 3400},
        {"date": "2025-05-02", "view_num": 1350, "exposure_num": 3800},
        {"date": "2025-05-03", "view_num": 1100, "exposure_num": 3100},
        {"date": "2025-05-04", "view_num": 1400, "exposure_num": 4000},
        {"date": "2025-05-05", "view_num": 1600, "exposure_num": 4500},
        {"date": "2025-05-06", "view_num": 1500, "exposure_num": 4200},
        {"date": "2025-05-07", "view_num": 1700, "exposure_num": 4800},
    ]
}

favorites = {}  # user_id -> [{"type": "project", "target_id": 1}, ...]
comments = {}   # news_id -> [{"comment_id": 1, "user_id": xx, "username": xx, "content": xx, "create_time": xx}]

# 初始化一些评论
comments[1] = [
    {"comment_id": 1, "user_id": 3, "username": "user1", "content": "好活动，支持！希望能在我们学校也能举办。",
     "create_time": "2025-05-11 10:00:00"},
    {"comment_id": 2, "user_id": 1, "username": "admin", "content": "感谢关注，我们会逐步扩大活动范围。",
     "create_time": "2025-05-11 11:00:00"},
]

next_ids = {"user": 4, "category": 5, "project": 9, "inheritor": 6, "news": 6, "channel": 6, "comment": 100}


def generate_token(user):
    """生成简单的mock token"""
    payload = f"{user['user_id']}:{user['username']}:{user['role']}:{int(time.time()) + 7*24*3600}"
    return base64.b64encode(payload.encode()).decode()


def parse_token(token_str):
    """解析mock token，返回用户信息或None"""
    try:
        if not token_str or not token_str.startswith("Bearer "):
            return None
        token = token_str[7:]
        payload = base64.b64decode(token).decode()
        parts = payload.split(":")
        if len(parts) < 4:
            return None
        user_id = int(parts[0])
        exp = int(parts[3])
        if time.time() > exp:
            return None
        return {"user_id": user_id, "username": parts[1], "role": parts[2]}
    except:
        return None


def get_current_user():
    """从请求头获取当前登录用户"""
    auth = request.headers.get("Authorization", "")
    return parse_token(auth)


def require_login():
    user = get_current_user()
    if not user:
        return jsonify({"code": 401, "msg": "未登录或Token已失效", "data": None}), 401
    return user


def require_role(*roles):
    user = get_current_user()
    if not user:
        return jsonify({"code": 401, "msg": "未登录或Token已失效", "data": None}), 401, None
    if user["role"] not in roles:
        return jsonify({"code": 403, "msg": "权限不足", "data": None}), 403, None
    return None, None, user


# ============================================================
# 静态文件服务
# ============================================================

@app.route('/')
def index():
    return send_from_directory('frontend', 'login.html')


@app.route('/<path:path>')
def static_files(path):
    if os.path.isfile(os.path.join('frontend', path)):
        return send_from_directory('frontend', path)
    return send_from_directory('frontend', 'index.html')


# ============================================================
# 认证接口
# ============================================================

@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    if not data:
        return jsonify({"code": 400, "msg": "请求数据不能为空", "data": None})
    username = data.get("username", "").strip()
    password = data.get("password", "").strip()
    role = data.get("role", "user")
    if not username or not password:
        return jsonify({"code": 400, "msg": "用户名和密码不能为空", "data": None})
    for u in users:
        if u["username"] == username:
            return jsonify({"code": 400, "msg": "用户名已存在", "data": None})
    if role not in ("user", "editor", "admin"):
        role = "user"
    new_user = {
        "user_id": next_ids["user"],
        "username": username,
        "password": password,
        "role": role,
        "create_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    next_ids["user"] += 1
    users.append(new_user)
    return jsonify({"code": 200, "msg": "注册成功", "data": {"user_id": new_user["user_id"], "username": username, "role": role}})


@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    if not data:
        return jsonify({"code": 400, "msg": "请求数据不能为空", "data": None})
    username = data.get("username", "").strip()
    password = data.get("password", "").strip()
    for u in users:
        if u["username"] == username and u["password"] == password:
            token = generate_token(u)
            return jsonify({
                "code": 200, "msg": "登录成功",
                "data": {
                    "token": token,
                    "user": {"user_id": u["user_id"], "username": u["username"], "role": u["role"]}
                }
            })
    return jsonify({"code": 400, "msg": "用户名或密码错误", "data": None})


@app.route('/api/auth/me', methods=['GET'])
def user_me():
    user = require_login()
    if isinstance(user, tuple):
        return user
    for u in users:
        if u["user_id"] == user["user_id"]:
            return jsonify({
                "code": 200, "msg": "success",
                "data": {"user_id": u["user_id"], "username": u["username"], "role": u["role"], "create_time": u["create_time"]}
            })
    return jsonify({"code": 404, "msg": "用户不存在", "data": None})


# ============================================================
# 非遗分类接口
# ============================================================

@app.route('/api/categories', methods=['GET'])
def get_categories():
    page = request.args.get("page", 1, type=int)
    size = request.args.get("size", 10, type=int)
    total = len(categories)
    start = (page - 1) * size
    paged = categories[start:start + size]
    return jsonify({
        "code": 200, "msg": "success",
        "data": {"total": total, "page": page, "size": size, "list": paged}
    })


@app.route('/api/categories', methods=['POST'])
def create_category():
    err, resp, user = require_role("admin")
    if err:
        return err
    data = request.get_json()
    if not data or not data.get("category_name", "").strip():
        return jsonify({"code": 400, "msg": "分类名称不能为空", "data": None})
    for c in categories:
        if c["category_name"] == data["category_name"].strip():
            return jsonify({"code": 400, "msg": "分类名称已存在", "data": None})
    new_cat = {
        "category_id": next_ids["category"],
        "category_name": data["category_name"].strip(),
        "category_desc": data.get("category_desc", "").strip()
    }
    next_ids["category"] += 1
    categories.append(new_cat)
    return jsonify({"code": 200, "msg": "分类创建成功", "data": {"category_id": new_cat["category_id"]}})


@app.route('/api/categories/<int:cid>', methods=['PUT'])
def update_category(cid):
    err, resp, user = require_role("admin")
    if err:
        return err
    for c in categories:
        if c["category_id"] == cid:
            data = request.get_json()
            if data:
                if "category_name" in data and data["category_name"].strip():
                    c["category_name"] = data["category_name"].strip()
                if "category_desc" in data:
                    c["category_desc"] = data["category_desc"].strip()
            return jsonify({"code": 200, "msg": "分类更新成功", "data": None})
    return jsonify({"code": 404, "msg": "分类不存在", "data": None})


@app.route('/api/categories/<int:cid>', methods=['DELETE'])
def delete_category(cid):
    err, resp, user = require_role("admin")
    if err:
        return err
    # 检查是否有项目使用此分类
    for p in projects:
        if p["category_id"] == cid:
            return jsonify({"code": 400, "msg": "该分类下存在非遗项目，无法删除", "data": None})
    for i, c in enumerate(categories):
        if c["category_id"] == cid:
            categories.pop(i)
            return jsonify({"code": 200, "msg": "删除成功", "data": None})
    return jsonify({"code": 404, "msg": "分类不存在", "data": None})


# ============================================================
# 非遗项目接口
# ============================================================

@app.route('/api/projects', methods=['GET'])
def get_projects():
    category_id = request.args.get("category_id", type=int)
    area = request.args.get("area", "").strip()
    keyword = request.args.get("keyword", "").strip()
    page = request.args.get("page", 1, type=int)
    size = request.args.get("size", 10, type=int)
    if size > 50:
        size = 50

    result = projects
    if category_id:
        result = [p for p in result if p["category_id"] == category_id]
    if area:
        result = [p for p in result if area in p.get("area", "")]
    if keyword:
        result = [p for p in result if keyword in p["project_name"]]

    # 为每个项目添加传承人数
    for p in result:
        p["inheritor_count"] = len([i for i in inheritors if i["project_id"] == p["project_id"]])

    total = len(result)
    start = (page - 1) * size
    paged = result[start:start + size]

    return jsonify({
        "code": 200, "msg": "success",
        "data": {"total": total, "page": page, "size": size, "list": paged}
    })


@app.route('/api/projects/<int:pid>', methods=['GET'])
def get_project_detail(pid):
    for p in projects:
        if p["project_id"] == pid:
            project_inheritors = [i for i in inheritors if i["project_id"] == pid]
            detail = dict(p)
            detail["inheritors"] = project_inheritors
            return jsonify({"code": 200, "msg": "success", "data": detail})
    return jsonify({"code": 404, "msg": "项目不存在", "data": None})


@app.route('/api/projects', methods=['POST'])
def create_project():
    err, resp, user = require_role("admin", "editor")
    if err:
        return err
    data = request.get_json()
    if not data or not data.get("project_name", "").strip():
        return jsonify({"code": 400, "msg": "项目名称不能为空", "data": None})
    new_proj = {
        "project_id": next_ids["project"],
        "project_name": data["project_name"].strip(),
        "category_id": data.get("category_id", 1),
        "category_name": "",
        "area": data.get("area", "").strip(),
        "project_intro": data.get("project_intro", "").strip(),
        "create_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    for c in categories:
        if c["category_id"] == new_proj["category_id"]:
            new_proj["category_name"] = c["category_name"]
            break
    next_ids["project"] += 1
    projects.append(new_proj)
    # 处理关联传承人
    if data.get("inheritors"):
        for i_data in data["inheritors"]:
            inheritors.append({
                "inheritor_id": next_ids["inheritor"],
                "name": i_data.get("name", ""),
                "project_id": new_proj["project_id"],
                "project_name": new_proj["project_name"],
                "years": i_data.get("years", 0),
                "intro": i_data.get("intro", ""),
                "avatar": i_data.get("avatar")
            })
            next_ids["inheritor"] += 1
    return jsonify({"code": 200, "msg": "项目创建成功", "data": {"project_id": new_proj["project_id"]}})


@app.route('/api/projects/<int:pid>', methods=['PUT'])
def update_project(pid):
    err, resp, user = require_role("admin", "editor")
    if err:
        return err
    for p in projects:
        if p["project_id"] == pid:
            data = request.get_json()
            if data:
                if "project_name" in data and data["project_name"].strip():
                    p["project_name"] = data["project_name"].strip()
                if "category_id" in data:
                    p["category_id"] = data["category_id"]
                    for c in categories:
                        if c["category_id"] == p["category_id"]:
                            p["category_name"] = c["category_name"]
                            break
                if "area" in data:
                    p["area"] = data["area"].strip()
                if "project_intro" in data:
                    p["project_intro"] = data["project_intro"].strip()
            return jsonify({"code": 200, "msg": "项目更新成功", "data": None})
    return jsonify({"code": 404, "msg": "项目不存在", "data": None})


@app.route('/api/projects/<int:pid>', methods=['DELETE'])
def delete_project(pid):
    err, resp, user = require_role("admin")
    if err:
        return err
    for i, p in enumerate(projects):
        if p["project_id"] == pid:
            projects.pop(i)
            return jsonify({"code": 200, "msg": "删除成功", "data": None})
    return jsonify({"code": 404, "msg": "项目不存在", "data": None})


# ============================================================
# 传承人接口
# ============================================================

@app.route('/api/inheritors', methods=['GET'])
def get_inheritors():
    project_id = request.args.get("project_id", type=int)
    keyword = request.args.get("keyword", "").strip()
    page = request.args.get("page", 1, type=int)
    size = request.args.get("size", 10, type=int)

    result = inheritors
    if project_id:
        result = [i for i in result if i["project_id"] == project_id]
    if keyword:
        result = [i for i in result if keyword in i["name"]]

    total = len(result)
    start = (page - 1) * size
    paged = result[start:start + size]

    return jsonify({
        "code": 200, "msg": "success",
        "data": {"total": total, "page": page, "size": size, "list": paged}
    })


@app.route('/api/inheritors/<int:iid>', methods=['GET'])
def get_inheritor_detail(iid):
    for i in inheritors:
        if i["inheritor_id"] == iid:
            return jsonify({"code": 200, "msg": "success", "data": i})
    return jsonify({"code": 404, "msg": "传承人不存在", "data": None})


@app.route('/api/inheritors', methods=['POST'])
def create_inheritor():
    err, resp, user = require_role("admin", "editor")
    if err:
        return err
    data = request.get_json()
    if not data or not data.get("name", "").strip():
        return jsonify({"code": 400, "msg": "传承人姓名不能为空", "data": None})
    proj_name = ""
    for p in projects:
        if p["project_id"] == data.get("project_id"):
            proj_name = p["project_name"]
            break
    new_inheritor = {
        "inheritor_id": next_ids["inheritor"],
        "name": data["name"].strip(),
        "project_id": data.get("project_id", 1),
        "project_name": proj_name,
        "years": data.get("years", 0),
        "intro": data.get("intro", "").strip(),
        "avatar": data.get("avatar")
    }
    next_ids["inheritor"] += 1
    inheritors.append(new_inheritor)
    return jsonify({"code": 200, "msg": "传承人创建成功", "data": {"inheritor_id": new_inheritor["inheritor_id"]}})


@app.route('/api/inheritors/<int:iid>', methods=['PUT'])
def update_inheritor(iid):
    err, resp, user = require_role("admin", "editor")
    if err:
        return err
    for i in inheritors:
        if i["inheritor_id"] == iid:
            data = request.get_json()
            if data:
                if "name" in data and data["name"].strip():
                    i["name"] = data["name"].strip()
                if "project_id" in data:
                    i["project_id"] = data["project_id"]
                    for p in projects:
                        if p["project_id"] == i["project_id"]:
                            i["project_name"] = p["project_name"]
                            break
                if "years" in data:
                    i["years"] = data["years"]
                if "intro" in data:
                    i["intro"] = data["intro"].strip()
                if "avatar" in data:
                    i["avatar"] = data["avatar"]
            return jsonify({"code": 200, "msg": "传承人更新成功", "data": None})
    return jsonify({"code": 404, "msg": "传承人不存在", "data": None})


@app.route('/api/inheritors/<int:iid>', methods=['DELETE'])
def delete_inheritor(iid):
    err, resp, user = require_role("admin")
    if err:
        return err
    for i, inh in enumerate(inheritors):
        if inh["inheritor_id"] == iid:
            inheritors.pop(i)
            return jsonify({"code": 200, "msg": "删除成功", "data": None})
    return jsonify({"code": 404, "msg": "传承人不存在", "data": None})


# ============================================================
# 文化资讯接口
# ============================================================

@app.route('/api/news', methods=['GET'])
def get_news():
    page = request.args.get("page", 1, type=int)
    size = request.args.get("size", 10, type=int)
    keyword = request.args.get("keyword", "").strip()

    result = [n for n in news_list if n["status"] == "published"]
    if keyword:
        result = [n for n in result if keyword in n["title"]]

    total = len(result)
    start = (page - 1) * size
    paged = result[start:start + size]

    list_data = [{"news_id": n["news_id"], "title": n["title"], "summary": n["summary"],
                   "author": n["author"], "publish_time": n["publish_time"]} for n in paged]

    return jsonify({
        "code": 200, "msg": "success",
        "data": {"total": total, "page": page, "size": size, "list": list_data}
    })


@app.route('/api/news/<int:nid>', methods=['GET'])
def get_news_detail(nid):
    for n in news_list:
        if n["news_id"] == nid and n["status"] == "published":
            detail = dict(n)
            detail["comments_count"] = len(comments.get(nid, []))
            detail["comments"] = comments.get(nid, [])
            return jsonify({"code": 200, "msg": "success", "data": detail})
    return jsonify({"code": 404, "msg": "资讯不存在", "data": None})


@app.route('/api/news', methods=['POST'])
def create_news():
    err, resp, user = require_role("admin", "editor")
    if err:
        return err
    data = request.get_json()
    if not data or not data.get("title", "").strip() or not data.get("content", "").strip():
        return jsonify({"code": 400, "msg": "标题和内容不能为空", "data": None})
    new_news = {
        "news_id": next_ids["news"],
        "title": data["title"].strip(),
        "content": data["content"].strip(),
        "summary": data.get("summary", data["content"].strip()[:100]),
        "user_id": user["user_id"],
        "author": user["username"],
        "publish_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "status": data.get("status", "published")
    }
    next_ids["news"] += 1
    news_list.append(new_news)
    return jsonify({"code": 200, "msg": "资讯发布成功", "data": {"news_id": new_news["news_id"]}})


@app.route('/api/news/<int:nid>', methods=['PUT'])
def update_news(nid):
    err, resp, user = require_role("admin", "editor")
    if err:
        return err
    for n in news_list:
        if n["news_id"] == nid:
            if user["role"] != "admin" and n["user_id"] != user["user_id"]:
                return jsonify({"code": 403, "msg": "只能修改自己的资讯", "data": None})
            data = request.get_json()
            if data:
                if "title" in data and data["title"].strip():
                    n["title"] = data["title"].strip()
                if "content" in data and data["content"].strip():
                    n["content"] = data["content"].strip()
                if "summary" in data:
                    n["summary"] = data["summary"].strip()
                if "status" in data:
                    n["status"] = data["status"]
            return jsonify({"code": 200, "msg": "资讯更新成功", "data": None})
    return jsonify({"code": 404, "msg": "资讯不存在", "data": None})


@app.route('/api/news/<int:nid>', methods=['DELETE'])
def delete_news(nid):
    err, resp, user = require_role("admin", "editor")
    if err:
        return err
    for i, n in enumerate(news_list):
        if n["news_id"] == nid:
            if user["role"] != "admin" and n["user_id"] != user["user_id"]:
                return jsonify({"code": 403, "msg": "只能删除自己的资讯", "data": None})
            news_list.pop(i)
            return jsonify({"code": 200, "msg": "删除成功", "data": None})
    return jsonify({"code": 404, "msg": "资讯不存在", "data": None})


@app.route('/api/news/<int:nid>/audit', methods=['PUT'])
def audit_news(nid):
    err, resp, user = require_role("admin")
    if err:
        return err
    data = request.get_json()
    for n in news_list:
        if n["news_id"] == nid:
            n["status"] = data.get("status", "published")
            return jsonify({"code": 200, "msg": "审核完成", "data": None})
    return jsonify({"code": 404, "msg": "资讯不存在", "data": None})


@app.route('/api/news/<int:nid>/comments', methods=['GET'])
def get_comments(nid):
    page = request.args.get("page", 1, type=int)
    size = request.args.get("size", 20, type=int)
    cmts = comments.get(nid, [])
    total = len(cmts)
    start = (page - 1) * size
    paged = cmts[start:start + size]
    return jsonify({"code": 200, "msg": "success", "data": {"total": total, "list": paged}})


@app.route('/api/news/<int:nid>/comments', methods=['POST'])
def add_comment(nid):
    user_res = require_login()
    if isinstance(user_res, tuple):
        return user_res
    user = user_res
    data = request.get_json()
    if not data or not data.get("content", "").strip():
        return jsonify({"code": 400, "msg": "评论内容不能为空", "data": None})
    if nid not in comments:
        comments[nid] = []
    new_comment = {
        "comment_id": next_ids["comment"],
        "user_id": user["user_id"],
        "username": user["username"],
        "content": data["content"].strip(),
        "create_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    next_ids["comment"] += 1
    comments[nid].append(new_comment)
    return jsonify({"code": 200, "msg": "评论成功", "data": new_comment})


# ============================================================
# 传播渠道接口
# ============================================================

@app.route('/api/channels', methods=['GET'])
def get_channels():
    return jsonify({"code": 200, "msg": "success", "data": channels})


@app.route('/api/channels', methods=['POST'])
def create_channel():
    err, resp, user = require_role("admin")
    if err:
        return err
    data = request.get_json()
    if not data or not data.get("channel_name", "").strip():
        return jsonify({"code": 400, "msg": "渠道名称不能为空", "data": None})
    new_ch = {
        "channel_id": next_ids["channel"],
        "channel_name": data["channel_name"].strip(),
        "channel_type": data.get("channel_type", "").strip(),
        "status": 1
    }
    next_ids["channel"] += 1
    channels.append(new_ch)
    return jsonify({"code": 200, "msg": "渠道创建成功", "data": {"channel_id": new_ch["channel_id"]}})


@app.route('/api/channels/<int:chid>', methods=['PUT'])
def update_channel(chid):
    err, resp, user = require_role("admin")
    if err:
        return err
    for ch in channels:
        if ch["channel_id"] == chid:
            data = request.get_json()
            if data:
                if "channel_name" in data and data["channel_name"].strip():
                    ch["channel_name"] = data["channel_name"].strip()
                if "channel_type" in data:
                    ch["channel_type"] = data["channel_type"].strip()
                if "status" in data:
                    ch["status"] = data["status"]
            return jsonify({"code": 200, "msg": "渠道更新成功", "data": None})
    return jsonify({"code": 404, "msg": "渠道不存在", "data": None})


@app.route('/api/channels/<int:chid>', methods=['DELETE'])
def delete_channel(chid):
    err, resp, user = require_role("admin")
    if err:
        return err
    for i, ch in enumerate(channels):
        if ch["channel_id"] == chid:
            channels.pop(i)
            return jsonify({"code": 200, "msg": "删除成功", "data": None})
    return jsonify({"code": 404, "msg": "渠道不存在", "data": None})


# ============================================================
# 传播数据统计接口
# ============================================================

@app.route('/api/stats/channel', methods=['GET'])
def stats_channel():
    return jsonify({"code": 200, "msg": "success", "data": stats_channel})


@app.route('/api/stats/project', methods=['GET'])
def stats_project_data():
    return jsonify({"code": 200, "msg": "success", "data": stats_project})


@app.route('/api/stats/project/<int:pid>/trend', methods=['GET'])
def stats_project_trend(pid):
    data = trend_data.get(pid, [
        {"date": "2025-05-01", "view_num": 500, "exposure_num": 1500},
        {"date": "2025-05-02", "view_num": 600, "exposure_num": 1800},
    ])
    return jsonify({"code": 200, "msg": "success", "data": data})


@app.route('/api/stats/record', methods=['POST'])
def add_stat_record():
    err, resp, user = require_role("admin")
    if err:
        return err
    return jsonify({"code": 200, "msg": "数据录入成功", "data": None})


# ============================================================
# 全局搜索接口
# ============================================================

@app.route('/api/search', methods=['GET'])
def search():
    keyword = request.args.get("keyword", "").strip()
    if not keyword:
        return jsonify({"code": 400, "msg": "搜索关键词不能为空", "data": None})
    results = []
    for p in projects:
        if keyword in p["project_name"] or keyword in p.get("area", "") or keyword in p.get("project_intro", ""):
            results.append({"type": "project", "id": p["project_id"], "name": p["project_name"],
                           "area": p.get("area", ""), "description": p.get("project_intro", "")[:80]})
    for i in inheritors:
        if keyword in i["name"]:
            results.append({"type": "inheritor", "id": i["inheritor_id"], "name": i["name"],
                           "project_name": i["project_name"], "description": i.get("intro", "")[:80]})
    for n in news_list:
        if n["status"] == "published" and keyword in n["title"]:
            results.append({"type": "news", "id": n["news_id"], "name": n["title"],
                           "description": n.get("summary", "")[:80]})
    return jsonify({"code": 200, "msg": "success", "data": results})


# ============================================================
# 收藏接口
# ============================================================

@app.route('/api/favorite/toggle', methods=['POST'])
def toggle_favorite():
    user_res = require_login()
    if isinstance(user_res, tuple):
        return user_res
    user = user_res
    data = request.get_json()
    fav_type = data.get("type")
    target_id = data.get("target_id")
    if fav_type not in ("project", "news") or not target_id:
        return jsonify({"code": 400, "msg": "参数错误", "data": None})
    uid = user["user_id"]
    if uid not in favorites:
        favorites[uid] = []
    for f in favorites[uid]:
        if f["type"] == fav_type and f["target_id"] == target_id:
            favorites[uid].remove(f)
            return jsonify({"code": 200, "msg": "已取消收藏", "data": None})
    favorites[uid].append({"type": fav_type, "target_id": target_id})
    return jsonify({"code": 200, "msg": "已收藏", "data": None})


@app.route('/api/favorites', methods=['GET'])
def get_favorites():
    user_res = require_login()
    if isinstance(user_res, tuple):
        return user_res
    user = user_res
    fav_type = request.args.get("type", "")
    uid = user["user_id"]
    user_favs = favorites.get(uid, [])
    if fav_type:
        user_favs = [f for f in user_favs if f["type"] == fav_type]
    result = []
    for f in user_favs:
        if f["type"] == "project":
            for p in projects:
                if p["project_id"] == f["target_id"]:
                    result.append({"type": "project", "target_id": p["project_id"], "name": p["project_name"]})
        elif f["type"] == "news":
            for n in news_list:
                if n["news_id"] == f["target_id"]:
                    result.append({"type": "news", "target_id": n["news_id"], "name": n["title"]})
    return jsonify({"code": 200, "msg": "success", "data": result})


# ============================================================
# 启动服务
# ============================================================

if __name__ == '__main__':
    print("=" * 60)
    print("  非遗文化数字化传播系统 - Mock版后端服务")
    print("  访问地址: http://localhost:8080")
    print("  接口基础地址: http://localhost:8080/api")
    print("=" * 60)
    print("  测试账号:")
    print("    管理员: admin / 123456")
    print("    编辑者: editor1 / 123456")
    print("    普通用户: user1 / 123456")
    print("=" * 60)
    app.run(host='0.0.0.0', port=8080, debug=True)
