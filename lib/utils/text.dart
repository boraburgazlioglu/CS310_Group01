import 'package:flutter/material.dart';
import 'colors.dart';

class AppTexts{

  // 3 heading sizes
  static const TextStyle headL = TextStyle(
    fontFamily: 'Limelight',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headM = TextStyle(
    fontFamily: 'Limelight',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headS = TextStyle(
    fontFamily: 'Limelight',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // 3 body styles
  static const TextStyle bodyL = TextStyle(
    fontFamily: 'Limelight',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyM = TextStyle(
    fontFamily: 'Limelight',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );


  static const TextStyle bodyS = TextStyle(
    fontFamily: 'Limelight',
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Limelight',
    fontSize: 16,
    fontWeight: FontWeight.w500, //not as bold as heading
    color: AppColors.textPrimary,
  );
}