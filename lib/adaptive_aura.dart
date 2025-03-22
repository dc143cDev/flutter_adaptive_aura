library adaptive_aura;

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// Imports for internal implementation
import 'src/models/aura_color_palette.dart';
import 'src/styles/aura_style_layer.dart';

// Export model classes
export 'src/models/aura_color_palette.dart';

// Export style classes
export 'src/styles/aura_style_layer.dart';
export 'src/styles/blob_style_layer.dart';
export 'src/styles/full_color_style_layer.dart';
export 'src/styles/sunray_style_layer.dart';

// Include internal implementation files
part 'src/color_extractor.dart';
part 'src/adaptive_aura_container.dart';

// Define and export aura style enum
/// Aura style enum
enum AuraStyle {
  /// Blob style (default)
  BLOB,

  /// Full color style (Apple Music style)
  FULL_COLOR,

  /// Sunray style (NEW)
  SUNRAY,
}

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}
