import 'package:flutter/material.dart';
import 'package:sergipe_shop/utils/app_colors.dart';

class SnackBarMessage {
  static error(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg),
      ),
    );
  }

  static sucess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.verde,
        content: Text(msg),
      ),
    );
  }
}
