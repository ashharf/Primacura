/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Poppins-Regular.ttf
  String get poppinsRegular => 'assets/fonts/Poppins-Regular.ttf';

  /// List of all assets
  List<String> get values => [poppinsRegular];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/a_12.png
  AssetGenImage get a12 => const AssetGenImage('assets/icons/a_12.png');

  /// File path: assets/icons/acharya_logo.png
  AssetGenImage get acharyaLogo =>
      const AssetGenImage('assets/icons/acharya_logo.png');

  /// File path: assets/icons/app-logo.png
  AssetGenImage get appLogo => const AssetGenImage('assets/icons/app-logo.png');

  /// File path: assets/icons/blood_pressure.svg
  String get bloodPressure => 'assets/icons/blood_pressure.svg';

  /// File path: assets/icons/doctor_symbol.jpg
  AssetGenImage get doctorSymbol =>
      const AssetGenImage('assets/icons/doctor_symbol.jpg');

  /// File path: assets/icons/google_icon.svg
  String get googleIcon => 'assets/icons/google_icon.svg';

  /// File path: assets/icons/rod-of-asclepius.jpg
  AssetGenImage get rodOfAsclepius =>
      const AssetGenImage('assets/icons/rod-of-asclepius.jpg');

  /// File path: assets/icons/signature.png
  AssetGenImage get signature =>
      const AssetGenImage('assets/icons/signature.png');

  /// File path: assets/icons/splash_icon.png
  AssetGenImage get splashIcon =>
      const AssetGenImage('assets/icons/splash_icon.png');

  /// List of all assets
  List<dynamic> get values => [
        a12,
        acharyaLogo,
        appLogo,
        bloodPressure,
        doctorSymbol,
        googleIcon,
        rodOfAsclepius,
        signature,
        splashIcon
      ];
}

class Assets {
  Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const String indianMedicines = 'assets/indian_medicines.json';

  /// List of all assets
  static List<String> get values => [indianMedicines];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
