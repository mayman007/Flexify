import 'package:flutter/material.dart';

// Custom PageRoute to set the duration of the Hero animation
class CustomPageRoute<T> extends MaterialPageRoute<T> {
  final Duration duration;

  CustomPageRoute({required super.builder, required this.duration});

  @override
  Duration get transitionDuration => duration;
}
