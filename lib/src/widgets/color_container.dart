import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class ColorContainer extends StatefulWidget {
  final Color containerColor;

  const ColorContainer({super.key, required this.containerColor});

  @override
  State<ColorContainer> createState() => _ColorContainerState();
}

class _ColorContainerState extends State<ColorContainer> {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message:
          "#${widget.containerColor.value.toRadixString(16).toUpperCase()}",
      child: GestureDetector(
        onLongPress: () async {
          await Clipboard.setData(ClipboardData(
              text:
                  "#${widget.containerColor.value.toRadixString(16).toUpperCase()}"));
          showToast(
            "Copied #${widget.containerColor.value.toRadixString(16).toUpperCase()}",
            duration: const Duration(seconds: 1),
            animation: StyledToastAnimation.fade,
            reverseAnimation: StyledToastAnimation.fade,
            // ignore: use_build_context_synchronously
            context: context,
          );
        },
        child: Container(
          height: 25,
          width: 25,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: widget.containerColor,
          ),
        ),
      ),
    );
  }
}
