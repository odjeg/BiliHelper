class VideoState {
  String? bvid;
  int? aid;
  int? videos;
  int? tid;
  String? tname;
  int? copyright;
  String? pic;
  String? title;
  int? pubdate;
  int? ctime;
  String? desc;
  List<dynamic>? descV2;
  int? state;
  int? duration;
  int? missionId;
  Map<String, dynamic>? rights;
  //以下为owner字段
  int? mid;
  String? name;
  String? face;
  //以下为state字段
  int? view; //播放数
  int? danmaku; //弹幕数
  int? reply; //评论数
  int? favorite; //收藏数
  int? coin; //投币数
  int? share; //分享数
  int? like; //点赞数

  VideoState.fromJson(Map<String, dynamic> json) {
    bvid = json['bvid'];
    aid = json['aid'];
    videos = json['videos'];
    tid = json['tid'];
    tname = json['tname'];
    copyright = json['copyright'];
    pic = json['pic'];
    title = json['title'];
    pubdate = json['pubdate'];
    ctime = json['ctime'];
    desc = json['desc'];
    descV2 = json['desc_v2'];
    state = json['state'];
    duration = json['duration'];
    missionId = json['mission_id'];
    rights = json['rights'];
    mid = json['owner']['mid'];
    name = json['owner']['name'];
    face = json['owner']['face'];
    view = json['stat']['view'];
    danmaku = json['stat']['danmaku'];
    reply = json['stat']['reply'];
    favorite = json['stat']['favorite'];
    coin = json['stat']['coin'];
    share = json['stat']['share'];
    like = json['stat']['like'];
  }
}



















/*
{
  "code": 0,
  "message": "0",
  "ttl": 1,
  "data": {
    "bvid": "BV117411r7R1",
    "aid": 85440373,
    "videos": 1,
    "tid": 28,
    "tname": "原创音乐",
    "copyright": 1,
    "pic": "http://i1.hdslb.com/bfs/archive/ea0dd34bf41e23a68175680a00e3358cd249105f.jpg",
    "title": "当我给拜年祭的快板加了电音配乐…",
    "pubdate": 1580377255,
    "ctime": 1580212263,
    "desc": "【CB想说的】看完拜年祭之后最爱的一个节目！给有快板的部分简单加了一些不同风格的配乐hhh，感谢沃玛画的我！太可爱了哈哈哈哈哈哈哈！！！\n【Warma想说的】我画了打碟的CB，画风为了还原原版视频所以参考了四迹老师的画风，四迹老师的画真的太可爱啦！不过其实在画的过程中我遇到了一个问题，CB的耳机……到底是戴在哪个耳朵上呢？\n\n原版：av78977080\n编曲（配乐）：Crazy Bucket\n人声（配音）：Warma/谢拉\n曲绘：四迹/Warma\n动画：四迹/Crazy Bucket\n剧本：Mokurei-木灵君\n音频后期：DMYoung/纳兰寻风/Crazy Bucket\n包装：破晓天",
    "desc_v2": [
      {
        "raw_text": "【CB想说的】看完拜年祭之后最爱的一个节目！给有快板的部分简单加了一些不同风格的配乐hhh，感谢沃玛画的我！太可爱了哈哈哈哈哈哈哈！！！\n【Warma想说的】我画了打碟的CB，画风为了还原原版视频所以参考了四迹老师的画风，四迹老师的画真的太可爱啦！不过其实在画的过程中我遇到了一个问题，CB的耳机……到底是戴在哪个耳朵上呢？\n\n原版：av78977080\n编曲（配乐）：Crazy Bucket\n人声（配音）：Warma/谢拉\n曲绘：四迹/Warma\n动画：四迹/Crazy Bucket\n剧本：Mokurei-木灵君\n音频后期：DMYoung/纳兰寻风/Crazy Bucket\n包装：破晓天",
        "type": 1,
        "biz_id": 0
      }
    ],
    "state": 0,
    "duration": 486,
    "mission_id": 11838,
    "rights": {
      "bp": 0,
      "elec": 0,
      "download": 1,
      "movie": 0,
      "pay": 0,
      "hd5": 1,
      "no_reprint": 1,
      "autoplay": 1,
      "ugc_pay": 0,
      "is_cooperation": 1,
      "ugc_pay_preview": 0,
      "no_background": 0,
      "clean_mode": 0,
      "is_stein_gate": 0,
      "is_360": 0,
      "no_share": 0,
      "arc_pay": 0,
      "free_watch": 0
    },
    "owner": {
      "mid": 66606350,
      "name": "Crazy_Bucket_陈楒潼",
      "face": "https://i2.hdslb.com/bfs/face/c9af3b32cf74baec5a4b65af8ca18ae5ff571f77.jpg"
    },
    "stat": {
      "aid": 85440373,
      "view": 2353489,
      "danmaku": 12026,
      "reply": 2648,
      "favorite": 58761,
      "coin": 72088,
      "share": 9539,
      "now_rank": 0,
      "his_rank": 55,
      "like": 159350,
      "dislike": 0,
      "evaluation": "",
      "vt": 0
    },
    "argue_info": {
      "argue_msg": "",
      "argue_type": 0,
      "argue_link": ""
    },
    "dynamic": "进来就出不去了！！！\n#全民音乐UP主##CB##warma##电音##快板##拜年祭##诸神的奥运##编曲##Remix#",
    "cid": 146044693,
    "dimension": {
      "width": 1920,
      "height": 1080,
      "rotate": 0
    },
    "premiere": null,
    "teenage_mode": 0,
    "is_chargeable_season": false,
    "is_story": false,
    "is_upower_exclusive": false,
    "is_upower_play": false,
    "enable_vt": 0,
    "vt_display": "",
    "no_cache": false,
    "pages": [
      {
        "cid": 146044693,
        "page": 1,
        "from": "vupload",
        "part": "建议改成：建议改成：诸 神 的 电 音 节（不是）",
        "duration": 486,
        "vid": "",
        "weblink": "",
        "dimension": {
          "width": 1920,
          "height": 1080,
          "rotate": 0
        }
      }
    ],
    "subtitle": {
      "allow_submit": false,
      "list": [
        {
          "id": 1061981378473780000,
          "lan": "ai-zh",
          "lan_doc": "中文（自动生成）",
          "is_lock": false,
          "subtitle_url": "",
          "type": 1,
          "id_str": "1061981378473779968",
          "ai_type": 0,
          "ai_status": 2,
          "author": {
            "mid": 0,
            "name": "",
            "sex": "",
            "face": "",
            "sign": "",
            "rank": 0,
            "birthday": 0,
            "is_fake_account": 0,
            "is_deleted": 0,
            "in_reg_audit": 0,
            "is_senior_member": 0
          }
        }
      ]
    },
    "staff": [
      {
        "mid": 66606350,
        "title": "UP主",
        "name": "Crazy_Bucket_陈楒潼",
        "face": "https://i2.hdslb.com/bfs/face/c9af3b32cf74baec5a4b65af8ca18ae5ff571f77.jpg",
        "vip": {
          "type": 2,
          "status": 1,
          "due_date": 1706112000000,
          "vip_pay_type": 0,
          "theme_type": 0,
          "label": {
            "path": "",
            "text": "年度大会员",
            "label_theme": "annual_vip",
            "text_color": "#FFFFFF",
            "bg_style": 1,
            "bg_color": "#FB7299",
            "border_color": "",
            "use_img_label": true,
            "img_label_uri_hans": "",
            "img_label_uri_hant": "",
            "img_label_uri_hans_static": "https://i0.hdslb.com/bfs/vip/8d4f8bfc713826a5412a0a27eaaac4d6b9ede1d9.png",
            "img_label_uri_hant_static": "https://i0.hdslb.com/bfs/activity-plat/static/20220614/e369244d0b14644f5e1a06431e22a4d5/VEW8fCC0hg.png"
          },
          "avatar_subscript": 1,
          "nickname_color": "#FB7299",
          "role": 3,
          "avatar_subscript_url": "",
          "tv_vip_status": 0,
          "tv_vip_pay_type": 0,
          "tv_due_date": 0
        },
        "official": {
          "role": 1,
          "title": "bilibili 知名音乐UP主",
          "desc": "",
          "type": 0
        },
        "follower": 650859,
        "label_style": 0
      },
      {
        "mid": 53456,
        "title": "曲绘",
        "name": "Warma",
        "face": "https://i2.hdslb.com/bfs/face/c1bbee6d255f1e7fc434e9930f0f288c8b24293a.jpg",
        "vip": {
          "type": 2,
          "status": 1,
          "due_date": 1738339200000,
          "vip_pay_type": 0,
          "theme_type": 0,
          "label": {
            "path": "",
            "text": "年度大会员",
            "label_theme": "annual_vip",
            "text_color": "#FFFFFF",
            "bg_style": 1,
            "bg_color": "#FB7299",
            "border_color": "",
            "use_img_label": true,
            "img_label_uri_hans": "https://i0.hdslb.com/bfs/activity-plat/static/20220608/e369244d0b14644f5e1a06431e22a4d5/0DFy9BHgwE.gif",
            "img_label_uri_hant": "",
            "img_label_uri_hans_static": "https://i0.hdslb.com/bfs/vip/8d7e624d13d3e134251e4174a7318c19a8edbd71.png",
            "img_label_uri_hant_static": "https://i0.hdslb.com/bfs/activity-plat/static/20220614/e369244d0b14644f5e1a06431e22a4d5/uckjAv3Npy.png"
          },
          "avatar_subscript": 1,
          "nickname_color": "#FB7299",
          "role": 3,
          "avatar_subscript_url": "",
          "tv_vip_status": 1,
          "tv_vip_pay_type": 1,
          "tv_due_date": 1721145600
        },
        "official": {
          "role": 1,
          "title": "bilibili 知名UP主",
          "desc": "",
          "type": 0
        },
        "follower": 4223581,
        "label_style": 0
      }
    ],
    "is_season_display": false,
    "user_garb": {
      "url_image_ani_cut": "https://i0.hdslb.com/bfs/garb/item/311b29b795eb3f09ed0401a56eddf5c90b8fbfd6.bin"
    },
    "honor_reply": {
      "honor": [
        {
          "aid": 85440373,
          "type": 2,
          "desc": "第45期每周必看",
          "weekly_recommend_num": 45
        },
        {
          "aid": 85440373,
          "type": 3,
          "desc": "全站排行榜最高第55名",
          "weekly_recommend_num": 0
        },
        {
          "aid": 85440373,
          "type": 4,
          "desc": "热门",
          "weekly_recommend_num": 0
        }
      ]
    },
    "like_icon": "",
    "need_jump_bv": false,
    "disable_show_up_info": false
  }
}
*/