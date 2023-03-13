import 'package:flutter/material.dart';

class ImageButton extends StatelessWidget {
  const ImageButton(this.text,
      {required this.img, required this.onPressed, this.onLongPress, Key? key})
      : super(key: key);
  final Widget img;
  final Text text;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
      onLongPress: onLongPress,
      onPressed: onPressed,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(10),
                  ),
                  child: img),
            ),
            text
          ],
        ),
      ),
    );
  }
}
