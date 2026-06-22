import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final source = img.decodePng(File('assets/icon/source_logo.png').readAsBytesSync())!;

  final size = source.width > source.height ? source.width : source.height;
  final canvas = img.Image(width: size, height: size, numChannels: 4);

  // Sample the source's top-left corner color to fill the padding bars so
  // the letterboxing blends with the logo's existing background.
  final fill = source.getPixel(0, 0);
  img.fill(canvas, color: fill);

  final dx = (size - source.width) ~/ 2;
  final dy = (size - source.height) ~/ 2;
  img.compositeImage(canvas, source, dstX: dx, dstY: dy);

  File('assets/icon/icon.png').writeAsBytesSync(img.encodePng(canvas));
  stdout.writeln('Wrote assets/icon/icon.png (${size}x$size)');
}
