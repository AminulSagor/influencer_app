import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_palette.dart';

class KVRow extends StatelessWidget {
  final String k;
  final String v;
  final bool strong;
  const KVRow({super.key, required this.k, required this.v, this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            k,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w300,
              color: AppPalette.black,
            ),
          ),
        ),

        10.w.horizontalSpace,

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            v,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
              color:AppPalette.primary,
            ),
          ),
        ),
      ],
    );
  }
}