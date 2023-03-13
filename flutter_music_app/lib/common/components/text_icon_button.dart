import 'package:flutter/material.dart';

class TextIconButton extends StatelessWidget {
  const TextIconButton({Key? key,
    required this.text,
    required this.icon,
    required this.onPressed, this.style})
      : super(key: key);

  final Text text;
  final Icon icon;
  final VoidCallback? onPressed;

  final ButtonStyle? style;
  @override
  Widget build(BuildContext context) {
  return TextButton(
  style: style ,
  onPressed: onPressed,
  child: Center(
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  icon,
  const SizedBox(
  height: 3,
  ),
  text
  ],
  ),
  ));
  }
}