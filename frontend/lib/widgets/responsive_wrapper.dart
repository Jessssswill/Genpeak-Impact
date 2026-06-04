import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color backgroundColor;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 500,
    this.backgroundColor = const Color(0xFF000000), // Default to pitch black outside the frame
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor, // Background color outside the frame
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            // Adds a subtle shadow and clipping for the mobile frame illusion on desktop
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 40,
                  spreadRadius: 10,
                )
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
