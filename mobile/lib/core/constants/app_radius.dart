import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double sm   = 10.0;
  static const double md   = 16.0;
  static const double lg   = 20.0;
  static const double xl   = 26.0;
  static const double pill = 100.0;

  static BorderRadius get small   => BorderRadius.circular(sm);
  static BorderRadius get medium  => BorderRadius.circular(md);
  static BorderRadius get large   => BorderRadius.circular(lg);
  static BorderRadius get xLarge  => BorderRadius.circular(xl);
  static BorderRadius get rounded => BorderRadius.circular(pill);
}