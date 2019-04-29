import 'package:cocktail_rush/firestoredimage/cache/firebase_image_provider.dart';
import 'package:cocktail_rush/firestoredimage/cache/firebase_image_url.dart';
import 'package:cocktail_rush/firestoredimage/firestored_image.dart';
import 'package:flutter/material.dart';

class CircleBorderImage extends StatelessWidget {
  final String imageUrl;

  final double diameter;
  final Color borderColor;
  final double padding;

  CircleBorderImage(
      {@required this.imageUrl,
      @required this.diameter,
      double padding,
      Color borderColor})
      : borderColor = borderColor ?? Colors.pink[50],
        padding = padding ?? 8.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      constraints: BoxConstraints.tight(Size(diameter, diameter)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(diameter),
        border: Border.all(
          width: 1.0,
          color: borderColor,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, padding, padding, padding),
        child: FireStoredImage(
            width: diameter,
            height: diameter,
            // placeholder: new Icon(Icons.image, size: 50.0, color: Colors.pink[50]),
            errorWidget:
                new Icon(Icons.error, size: 50.0, color: Colors.pink[50]),
            imageProvider: FireBaseImageProvider(FireBaseUrl(
                nodes: List<String>()..add("cocktails")..add("big"),
                image: imageUrl))),
      ),
    );
  }
}
