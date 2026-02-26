import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bilibilihelper/utils/bili_x_api.dart';

class UserCardWidget extends StatefulWidget {
  final int mid;

  const UserCardWidget({super.key, required this.mid});

  @override
  State<UserCardWidget> createState() => _UserCardWidgetState();
}

class _UserCardWidgetState extends State<UserCardWidget> {
  String name = '';
  String mid = '';
  String? face;
  int friend = 0;
  int follower = 0;
  int like_num = 0;
  String sign = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initUserCard();
  }

  Future<void> _initUserCard() async {
    log('获取用户卡片信息 mid: ${widget.mid}');
    //https://api.bilibili.com/x/web-interface/card?mid=391385119&photo=true&web_location=333.1387
    Response<dynamic> response = await api.get(
      '/web-interface/card',
      queryParameters: {
        'mid': widget.mid.toString(),
        'photo': 'true',
        'web_location': '333.1387',
      },
    );
    if (mounted) {
      //没有销毁，才更新
      setState(() {
        name = response.data['data']['card']['name'];
        mid = response.data['data']['card']['mid'];
        face = response.data['data']['card']['face'];
        friend = response.data['data']['card']['friend'];
        follower = response.data['data']['card']['fans'];
        like_num = response.data['data']['like_num'];
        sign = response.data['data']['card']['sign'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              face != null
                  ? Image.network(
                      face!,
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/image/empty.png',
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.cover,
                    ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 18),
                child: Column(
                  children: [
                    Text('$name'),
                    Text('$mid'),
                    Text('关注: $friend'),
                    Text('粉丝: $follower'),
                    Text('获赞: $like_num'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(padding: EdgeInsets.all(4.0), child: Text(sign)),
      ],
    );
  }
}
