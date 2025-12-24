import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Marble extends CircleComponent {
  Marble({super.position, super.radius = 10}) {
    paint = Paint()..color = Colors.blue;
  }
}
