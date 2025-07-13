// import 'dart:typed_data';
// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
//
// enum PhotographicStyle {
//   original,
//   smartHDR,
//   deepFusion,
//   richContrast,
//   vibrant,
//   warm,
//   cool,
// }
//
// Uint8List applyPhotographicFilter(Uint8List bytes, PhotographicStyle style) {
//   return applyPhotographicStyle(bytes, style);
// }
//
// Uint8List applyPhotographicStyle(
//   Uint8List originalBytes,
//   PhotographicStyle style,
// ) {
//   img.Image image = img.decodeImage(originalBytes)!;
//
//   switch (style) {
//     case PhotographicStyle.smartHDR:
//       return img.encodeJpg(
//         _boostContrastBrightness(image, contrast: 1.3, brightness: 10),
//       );
//     case PhotographicStyle.deepFusion:
//       return img.encodeJpg(_sharpen(image));
//     case PhotographicStyle.richContrast:
//       return img.encodeJpg(
//         _boostContrastBrightness(image, contrast: 1.4, brightness: -10),
//       );
//     case PhotographicStyle.vibrant:
//       return img.encodeJpg(_boostSaturation(image, 1.5));
//     case PhotographicStyle.warm:
//       return img.encodeJpg(_tintImage(image, redBoost: 20));
//     case PhotographicStyle.cool:
//       return img.encodeJpg(_tintImage(image, blueBoost: 20));
//     case PhotographicStyle.original:
//       return originalBytes;
//   }
// }
//
// img.Image _boostContrastBrightness(
//   img.Image src, {
//   double contrast = 1.0,
//   int brightness = 0,
// }) {
//   final result = img.Image.from(src);
//   for (var y = 0; y < result.height; y++) {
//     for (var x = 0; x < result.width; x++) {
//       final img.Pixel pixel = result.getPixel(x, y);
//       num r = pixel.r;
//       num g = pixel.g;
//       num b = pixel.b;
//
//       r = ((r - 128) * contrast + 128 + brightness).clamp(0, 255).toInt();
//       g = ((g - 128) * contrast + 128 + brightness).clamp(0, 255).toInt();
//       b = ((b - 128) * contrast + 128 + brightness).clamp(0, 255).toInt();
//
//       result.setPixelRgba(x, y, r, g, b, 255);
//     }
//   }
//   return result;
// }
//
// img.Image _boostSaturation(img.Image src, double saturation) {
//   final result = img.Image.from(src);
//   for (var y = 0; y < result.height; y++) {
//     for (var x = 0; x < result.width; x++) {
//       final img.Pixel pixel = result.getPixel(x, y);
//       num r = pixel.r;
//       num g = pixel.g;
//       num b = pixel.b;
//
//       double p = (r + g + b) / 3.0;
//       r = (p + (r - p) * saturation).clamp(0, 255).toInt();
//       g = (p + (g - p) * saturation).clamp(0, 255).toInt();
//       b = (p + (b - p) * saturation).clamp(0, 255).toInt();
//
//       result.setPixelRgba(x, y, r, g, b, 255);
//     }
//   }
//   return result;
// }
//
// img.Image _tintImage(img.Image src, {int redBoost = 0, int blueBoost = 0}) {
//   final result = img.Image.from(src);
//   for (var y = 0; y < result.height; y++) {
//     for (var x = 0; x < result.width; x++) {
//       final img.Pixel pixel = result.getPixel(x, y);
//       num r = pixel.r + redBoost;
//       num g = pixel.g;
//       num b = pixel.b + blueBoost;
//       r = r.clamp(0, 255).toInt();
//       b = b.clamp(0, 255).toInt();
//       result.setPixelRgba(x, y, r, g, b, 255);
//     }
//   }
//   return result;
// }
//
// img.Image _sharpen(img.Image src) {
//   final result = img.Image.from(src);
//   return img.convolution(result, filter: [0, -1, 0, -1, 5, -1, 0, -1, 0]);
// }
//
// class AdvancedPhotographicStyles extends StatefulWidget {
//   final Uint8List originalImageBytes;
//
//   const AdvancedPhotographicStyles({
//     super.key,
//     required this.originalImageBytes,
//   });
//
//   @override
//   State<AdvancedPhotographicStyles> createState() =>
//       _AdvancedPhotographicStylesState();
// }
//
// class _AdvancedPhotographicStylesState
//     extends State<AdvancedPhotographicStyles> {
//   String currentStyle = 'Original';
//
//   Widget applyStyle(String style, Widget child) {
//     switch (style) {
//       case 'Smart HDR':
//         return ColorFiltered(
//           colorFilter: const ColorFilter.matrix([
//             1.2, 0, 0, 0, 10, // Red
//             0, 1.2, 0, 0, 10, // Green
//             0, 0, 1.2, 0, 10, // Blue
//             0, 0, 0, 1, 0, // Alpha
//           ]),
//           child: child,
//         );
//
//       case 'Deep Fusion':
//         return Stack(
//           children: [
//             child,
//             BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
//               child: Container(color: Colors.transparent),
//             ),
//           ],
//         );
//
//       case 'Rich Contrast':
//         return ColorFiltered(
//           colorFilter: const ColorFilter.matrix([
//             1.4,
//             -0.2,
//             -0.2,
//             0,
//             -10,
//             -0.2,
//             1.4,
//             -0.2,
//             0,
//             -10,
//             -0.2,
//             -0.2,
//             1.4,
//             0,
//             -10,
//             0,
//             0,
//             0,
//             1,
//             0,
//           ]),
//           child: child,
//         );
//
//       case 'Vibrant':
//         return ColorFiltered(
//           colorFilter: const ColorFilter.matrix([
//             1.5,
//             0.1,
//             0.1,
//             0,
//             10,
//             0.1,
//             1.5,
//             0.1,
//             0,
//             10,
//             0.1,
//             0.1,
//             1.5,
//             0,
//             10,
//             0,
//             0,
//             0,
//             1,
//             0,
//           ]),
//           child: child,
//         );
//
//       case 'Warm':
//         return ColorFiltered(
//           colorFilter: ColorFilter.mode(
//             Colors.orangeAccent.withOpacity(0.15),
//             BlendMode.overlay,
//           ),
//           child: child,
//         );
//
//       case 'Cool':
//         return ColorFiltered(
//           colorFilter: ColorFilter.mode(
//             Colors.lightBlueAccent.withOpacity(0.15),
//             BlendMode.overlay,
//           ),
//           child: child,
//         );
//
//       default:
//         return child;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final imageWidget = Image.asset('assets/test.png', fit: BoxFit.cover);
//     final styledImage = applyStyle(currentStyle, imageWidget);
//
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           Positioned.fill(child: styledImage),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: ClipRRect(
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(24),
//               ),
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 20,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.1),
//                   ),
//                   child: SafeArea(
//                     top: false,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Choose a Style',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Wrap(
//                           spacing: 8,
//                           runSpacing: 10,
//                           children:
//                               [
//                                 'Original',
//                                 'Smart HDR',
//                                 'Deep Fusion',
//                                 'Rich Contrast',
//                                 'Vibrant',
//                                 'Warm',
//                                 'Cool',
//                               ].map((style) {
//                                 return ChoiceChip(
//                                   label: Text(style),
//                                   selected: currentStyle == style,
//                                   selectedColor: Colors.white,
//                                   labelStyle: TextStyle(
//                                     color:
//                                         currentStyle == style
//                                             ? Colors.blueAccent
//                                             : Colors.grey,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                   backgroundColor: Colors.white.withOpacity(
//                                     0.2,
//                                   ),
//                                   onSelected:
//                                       (_) =>
//                                           setState(() => currentStyle = style),
//                                 );
//                               }).toList(),
//                         ),
//                         const SizedBox(height: 20),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             onPressed: () {
//                               final resultBytes = applyPhotographicFilter(
//                                 widget.originalImageBytes,
//                                 _getEnumFromLabel(currentStyle),
//                               );
//                               Navigator.pop(context, resultBytes);
//                             },
//                             child: const Text(
//                               "Apply & Return",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   PhotographicStyle _getEnumFromLabel(String label) {
//     switch (label) {
//       case 'Smart HDR':
//         return PhotographicStyle.smartHDR;
//       case 'Deep Fusion':
//         return PhotographicStyle.deepFusion;
//       case 'Rich Contrast':
//         return PhotographicStyle.richContrast;
//       case 'Vibrant':
//         return PhotographicStyle.vibrant;
//       case 'Warm':
//         return PhotographicStyle.warm;
//       case 'Cool':
//         return PhotographicStyle.cool;
//       default:
//         return PhotographicStyle.original;
//     }
//   }
// }
