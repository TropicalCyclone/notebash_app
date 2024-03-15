import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeIcon extends StatelessWidget {
  final Color? color;
  final Color? foreground;
  final BorderRadius? borderRadius;
  final void Function() onTap;
  final String icon;
  final String label;
  const HomeIcon(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap,
      this.color,
      this.foreground,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final Widget svg = SvgPicture.asset(icon,
        colorFilter: ColorFilter.mode(
          foreground ?? Colors.white,
          BlendMode.srcIn,
        ),
        semanticsLabel: label);

    return Material(
      color: color ?? Theme.of(context).colorScheme.primary,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox.square(
              dimension: 36,
              child: svg,
            ),
            const SizedBox(height: 14),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: foreground ?? Colors.white))
          ],
        ),
      ),
    );
  }
}
