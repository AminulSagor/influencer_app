import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:influencer_app/core/theme/app_palette.dart';
import 'package:influencer_app/core/utils/constants.dart';

class CustomButton extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? btnColor;
  final Color? borderColor;
  final double? borderRadius;
  final VoidCallback? onTap;
  final String btnText;
  final Color? textColor;
  final bool? showBorder;
  final double? borderWidth;
  final TextStyle? textStyle;
  final bool isLoading;
  final bool isDisabled;

  final List<double>? dashPattern;

  final bool _isDotted;

  const CustomButton({
    super.key,
    this.height,
    this.btnColor,
    this.borderColor,
    required this.onTap,
    required this.btnText,
    this.textColor,
    this.width,
    this.borderRadius,
    this.showBorder = true,
    this.borderWidth,
    this.textStyle,
    this.dashPattern,
    this.isLoading = false,
    this.isDisabled = false,
  }) : _isDotted = false;

  const CustomButton.dotted({
    super.key,
    this.height,
    this.btnColor,
    this.borderColor,
    required this.onTap,
    required this.btnText,
    this.textColor,
    this.width,
    this.borderRadius,
    this.showBorder = false,
    this.borderWidth,
    this.textStyle,
    this.dashPattern,
    this.isLoading = false,
    this.isDisabled = false,
  }) : _isDotted = true;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: height ?? 31.h,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: btnColor ?? AppPalette.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? kBorderRadius.r,
            ),
            side: BorderSide(
              color: !showBorder!
                  ? Colors.transparent
                  : borderColor ?? AppPalette.defaultStroke,
              width: borderWidth ?? kBorderWidth0_5,
            ),
          ),
        ),
        onPressed: isDisabled ? null : onTap,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            isLoading ? 'Loading..' : btnText,
            style:
                textStyle ??
                TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.04,
                  color: textColor ?? AppPalette.black,
                ),
          ),
        ),
      ),
    );

    if (_isDotted) {
      return DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: dashPattern ?? [5, 5],
          strokeWidth: borderWidth ?? 1,
          padding: EdgeInsets.zero,
          radius: Radius.circular(borderRadius ?? kBorderRadius.r),
          color: borderColor ?? AppPalette.secondary,
        ),
        child: button,
      );
    }

    return button;
  }
}
