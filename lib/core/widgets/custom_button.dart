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
  final Gradient? gradient;

  final List<double>? dashPattern;

  final Widget? leading;
  final Widget? trailing;
  final double? iconGap;

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
    this.gradient,
    this.leading,
    this.trailing,
    this.iconGap,
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
    this.gradient,
    this.leading,
    this.trailing,
    this.iconGap,
  }) : _isDotted = true;

  @override
  Widget build(BuildContext context) {
    final gap = iconGap ?? 8.w;
    final hasLeading = leading != null;
    final hasTrailing = trailing != null;

    final bool disabled = isDisabled || onTap == null;

    final childContent = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLeading) ...[leading!, SizedBox(width: gap)],
          Text(
            isLoading ? 'Loading..' : btnText,
            style:
                (textStyle ??
                        TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.04,
                          color: textColor ?? AppPalette.black,
                        ))
                    .copyWith(
                      // optional: keep text slightly dim when disabled
                      color: (textStyle?.color ?? textColor ?? AppPalette.black)
                          .withAlpha(disabled ? 180 : 255),
                    ),
          ),
          if (hasTrailing) ...[SizedBox(width: gap), trailing!],
        ],
      ),
    );

    final baseColor = btnColor ?? AppPalette.secondary;
    final baseBorderColor = borderColor ?? AppPalette.defaultStroke;

    final Color paintedColor = disabled ? baseColor.withAlpha(180) : baseColor;

    final Color paintedBorderColor = disabled
        ? baseBorderColor.withAlpha(180)
        : baseBorderColor;

    final Gradient? paintedGradient = gradient == null
        ? null
        : (disabled
              ? LinearGradient(
                  begin: (gradient is LinearGradient)
                      ? (gradient as LinearGradient).begin
                      : Alignment.centerLeft,
                  end: (gradient is LinearGradient)
                      ? (gradient as LinearGradient).end
                      : Alignment.centerRight,
                  colors: (gradient is LinearGradient)
                      ? (gradient as LinearGradient).colors
                            .map((c) => c.withAlpha(180))
                            .toList()
                      : const [],
                  stops: (gradient is LinearGradient)
                      ? (gradient as LinearGradient).stops
                      : null,
                )
              : gradient);

    final button = Container(
      height: height ?? 34.h,
      width: width,
      decoration: BoxDecoration(
        color: paintedGradient == null ? paintedColor : null,
        gradient: paintedGradient,
        borderRadius: BorderRadius.circular(borderRadius ?? kBorderRadius.r),
        border: Border.all(
          color: !showBorder! ? Colors.transparent : paintedBorderColor,
          width: borderWidth ?? kBorderWidth0_5,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.transparent,
          disabledIconColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? kBorderRadius.r,
            ),
          ),
        ),
        onPressed: disabled ? null : onTap,
        child: childContent,
      ),
    );

    if (_isDotted) {
      return DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: dashPattern ?? [5, 5],
          strokeWidth: borderWidth ?? 1,
          padding: EdgeInsets.zero,
          radius: Radius.circular(borderRadius ?? kBorderRadius.r),
          color: disabled
              ? (borderColor ?? AppPalette.secondary).withAlpha(180)
              : (borderColor ?? AppPalette.secondary),
        ),
        child: button,
      );
    }

    return button;
  }
}
