import 'package:flutter/material.dart';

class AppPadding{
  static const double S = 5.0;
  static const double M = 10.0;
  static const double L = 15.0;
  static const double xl = 25.0;

  // all sides
  static const EdgeInsets allS = EdgeInsets.all(S);
  static const EdgeInsets allM = EdgeInsets.all(M);
  static const EdgeInsets allL = EdgeInsets.all(L);
  static const EdgeInsets allXL = EdgeInsets.all(xl);

  //horizontal + vertical
  static const EdgeInsets horiS = EdgeInsets.symmetric(horizontal: S);
  static const EdgeInsets horiM = EdgeInsets.symmetric(horizontal: M);
  static const EdgeInsets horiL = EdgeInsets.symmetric(horizontal: L);
  static const EdgeInsets horiXL = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets vertS = EdgeInsets.symmetric(vertical: S);
  static const EdgeInsets vertM = EdgeInsets.symmetric(vertical: M);
  static const EdgeInsets vertL = EdgeInsets.symmetric(vertical: L);
  static const EdgeInsets vertXL = EdgeInsets.symmetric(vertical: xl);

  //each direction
  static const EdgeInsets topS = EdgeInsets.only(top: S);
  static const EdgeInsets botS = EdgeInsets.only(bottom: S);
  static const EdgeInsets leftS = EdgeInsets.only(left: S);
  static const EdgeInsets rightS = EdgeInsets.only(right: S);

  static const EdgeInsets topM = EdgeInsets.only(top: M);
  static const EdgeInsets botM = EdgeInsets.only(bottom: M);
  static const EdgeInsets leftM = EdgeInsets.only(left: M);
  static const EdgeInsets rightM = EdgeInsets.only(right: M);

  static const EdgeInsets topL = EdgeInsets.only(top: L);
  static const EdgeInsets botL = EdgeInsets.only(bottom: L);
  static const EdgeInsets leftL = EdgeInsets.only(left: L);
  static const EdgeInsets rightL = EdgeInsets.only(right: L);

  static const EdgeInsets topXL = EdgeInsets.only(top: xl);
  static const EdgeInsets botXL = EdgeInsets.only(bottom: xl);
  static const EdgeInsets leftXL = EdgeInsets.only(left: xl);
  static const EdgeInsets rightXL = EdgeInsets.only(right: xl);
}