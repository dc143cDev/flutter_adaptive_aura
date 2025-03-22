import 'package:flutter/material.dart';

/// 앨범 정보를 담는 모델 클래스
class AlbumInfo {
  /// 앨범 제목
  final String title;

  /// 아티스트 이름
  final String artist;

  /// 앨범 커버 이미지
  final ImageProvider image;

  /// 생성자
  AlbumInfo({required this.title, required this.artist, required this.image});
}
