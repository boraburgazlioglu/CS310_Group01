import 'package:flutter/material.dart';
import 'colors.dart';

class AppTexts{

  // 3 heading sizes
  static const TextStyle headL = TextStyle(
    fontFamily: 'Merriweather',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle headM = TextStyle(
    fontFamily: 'Merriweather',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle headS = TextStyle(
    fontFamily: 'Merriweather',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // 3 body styles
  static const TextStyle bodyL = TextStyle(
    fontFamily: 'Merriweather',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyM = TextStyle(
    fontFamily: 'Merriweather',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );


  static const TextStyle bodyS = TextStyle(
    fontFamily: 'Merriweather',
    fontSize: 10,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Merriweather',
    fontSize: 16,
    fontWeight: FontWeight.w500, //not as bold as heading
    color: AppColors.textPrimary,
  );
}