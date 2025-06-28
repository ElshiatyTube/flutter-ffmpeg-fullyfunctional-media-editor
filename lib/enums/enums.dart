import 'package:flutter/material.dart';

enum CameraPosition {
  back(0),
  front(1);

  final int id;
  const CameraPosition(this.id);
}
enum ColorFilterWithName {
  transparent([Colors.transparent, Colors.transparent], 'transparent',
      Colors.transparent),
  white([Colors.white, Colors.transparent], 'black', Colors.white),
  whiteRadiant([Colors.white, Colors.transparent], 'white', Colors.white),

  blue([Colors.blue, Colors.transparent], 'blue',
      Colors.blue),
  yellow([ Color(0x00ffff00), Colors.transparent], 'yellow',
      Colors.yellow),
  orange([Color(0x00ffa500), Colors.transparent], 'orange',
      Colors.orange),
  red([Color(0x00ff0000), Colors.transparent], 'red',
      Colors.red),
  green([Color(0x00008000), Colors.transparent], 'green',
      Colors.green);

  final List<Color> filter;
  final String name;
  final Color orgColor;
  const ColorFilterWithName(this.filter, this.name, this.orgColor);
}
enum MediaType {
  remoteImage(0),
  remoteVideo(1),
  localImage(2),
  localVideo(3);

  final int id;
  const MediaType(this.id);
}
enum Transpose{
  none(0,''),
  clock(1,'transpose=1'),
  counterClock(2,'transpose=2'),
  upSideDown(3,'transpose=2,transpose=2');

  final int val;
  final String stringVal;
  const Transpose(this.val,this.stringVal);

}
enum ImageType {
  local(0),
  remote(1);

  final int id;
  const ImageType(this.id);
}

enum VideoType {
  local(0),
  remote(1);

  final int id;
  const VideoType(this.id);
}

enum VideoSpeedEnum {
  half('0.5x', 0.5),
  threeQuarters('0.75x', 0.75),
  normal('1x', 1.0),
  two('2x', 2.0),
  triple('3x', 3.0);

  final String name;
  final double speed;
  const VideoSpeedEnum(this.name, this.speed);
}
