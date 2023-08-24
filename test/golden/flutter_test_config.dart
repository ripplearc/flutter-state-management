/// ***************************************************
/// Copyright 2019-2020 eBay Inc.
///
/// Use of this source code is governed by a BSD-style
/// license that can be found in the LICENSE file or at
/// https://opensource.org/licenses/BSD-3-Clause
/// ***************************************************
///

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:logger/logger.dart';

/// Works just like [LocalFileComparator] but includes a [threshold] that, when
/// exceeded, marks the test as a failure.
class LocalFileComparatorWithThreshold extends LocalFileComparator {
  /// Threshold above which tests will be marked as failing.
  /// Ranges from 0 to 1, both inclusive.
  final double threshold;

  LocalFileComparatorWithThreshold(Uri testFile, this.threshold)
      : assert(threshold >= 0 && threshold <= 1),
        super(testFile);

  /// Copy of [LocalFileComparator]'s [compare] method, except for the fact that
  /// it checks if the [ComparisonResult.diffPercent] is not greater than
  /// [threshold] to decide whether this test is successful or a failure.
  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent <= threshold) {
      var logger = Logger();

      logger.w(
        'A difference of ${result.diffPercent * 100}% was found, but it is '
        'acceptable since it is not greater than the threshold of '
        '${threshold * 100}%',
      );

      return true;
    }

    if (!result.passed) {
      final error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }
    return result.passed;
  }
}

// If there is a big difference between the golden and the test image in the
// future, we should check two things:
// 1. What is the MacOS version of the CodeMagic build machine?
//   (We should keep it consistent with the MacOS version of the local machine.)
// 2. What is the Flutter version of the CodeMagic build machine?
//   (We specify the Flutter version in the CodeMagic yaml file.)
const _kGoldenTestsThreshold = 0.05 / 100;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  if (goldenFileComparator is LocalFileComparator) {
    final testUrl = (goldenFileComparator as LocalFileComparator).basedir;

    goldenFileComparator = LocalFileComparatorWithThreshold(
      // flutter_test's LocalFileComparator expects the test's URI to be passed
      // as an argument, but it only uses it to parse the baseDir in order to
      // obtain the directory where the golden tests will be placed.
      // As such, we use the default `testUrl`, which is only the `baseDir` and
      // append a generically named `test.dart` so that the `baseDir` is
      // properly extracted.
      Uri.parse('$testUrl/test.dart'),
      _kGoldenTestsThreshold,
    );
  } else {
    throw Exception(
      'Expected `goldenFileComparator` to be of type `LocalFileComparator`, '
      'but it is of type `${goldenFileComparator.runtimeType}`',
    );
  }
  return GoldenToolkit.runWithConfiguration(
    () async {
      await loadAppFonts();
      await testMain();
    },
    config: GoldenToolkitConfiguration(
      // Currently, goldens are not generated/validated in CI for this repo. We have settled on the goldens for this package
      // being captured/validated by developers running on MacOSX. We may revisit this in the future if there is a reason to invest
      // in more sophistication
      skipGoldenAssertion: () => !Platform.isMacOS,
    ),
  );
}
// iPhone SE (1st generation): 320.0 x 568.0 logical pixels
// iPhone 6, 6s, 7, and 8: 375.0 x 667.0 logical pixels
// iPhone SE (2nd generation): 375.0 x 667.0 logical pixels
// iPhone 6 Plus, 6s Plus, 7 Plus, and 8 Plus: 414.0 x 736.0 logical pixels
// iPhone X, XS, 11 Pro: 375.0 x 812.0 logical pixels
// iPhone XR, 11: 414.0 x 896.0 logical pixels
// iPhone XS Max, 11 Pro Max: 414.0 x 896.0 logical pixels
// iPhone 12, 12 Pro: 390.0 x 844.0 logical pixels
// iPhone 12 Mini: 360.0 x 780.0 logical pixels
// iPhone 12 Pro Max: 428.0 x 926.0 logical pixels
// iPhone 13, 13 Pro: 390.0 x 844.0 logical pixels
// iPhone 13 Mini: 360.0 x 780.0 logical pixels
// iPhone 13 Pro Max: 428.0 x 926.0 logical pixels

// iPad 1, 2, Mini (1st generation): 768.0 x 1024.0 logical pixels
// iPad 3, 4, Air (1st generation): 768.0 x 1024.0 logical pixels
// iPad Mini 2, Mini 3, Mini 4: 768.0 x 1024.0 logical pixels
// iPad Air 2: 768.0 x 1024.0 logical pixels
// iPad Pro 9.7-inch: 768.0 x 1024.0 logical pixels
// iPad (5th generation): 768.0 x 1024.0 logical pixels
// iPad Pro 10.5-inch: 834.0 x 1112.0 logical pixels
// iPad (6th, 7th, 8th generation): 768.0 x 1024.0 logical pixels
// iPad Air (3rd generation): 834.0 x 1112.0 logical pixels
// iPad Mini (5th generation): 768.0 x 1024.0 logical pixels
// iPad Pro 11-inch (1st and 2nd generation): 834.0 x 1194.0 logical pixels
// iPad Pro 12.9-inch (1st to 5th generation): 1024.0 x 1366.0 logical pixels

class DevicePool {
  static List<Device> devices = [
    iphone13Mini,
    iphone13Mini.landscape(),
    iphone13ProMax,
    iphone13ProMax.landscape(),
    ipadMini,
    ipadMini.landscape(),
    ipadPro13Inch,
    ipadPro13Inch.landscape(),
    webLaptop,
    webDesktop,
  ];

  static const safeArea = EdgeInsets.only(top: 44, bottom: 0);

  static const Device iphone13Mini =
      Device(name: 'iPhone13_mini', size: Size(360, 780), safeArea: safeArea);

  static const Device iphone13 =
      Device(name: 'iPhone13', size: Size(390, 844), safeArea: safeArea);

  static const Device iphone13ProMax =
      Device(name: 'iPhone13_ProMax', size: Size(428, 926), safeArea: safeArea);

  static const Device ipadMini =
      Device(name: 'iPad_Mini', size: Size(768, 1024), safeArea: safeArea);

  static const Device ipadPro11Inch = Device(
      name: 'iPad_Pro_11_inch', size: Size(834, 1194), safeArea: safeArea);

  static const Device ipadPro13Inch = Device(
      name: 'iPad_Pro_12_9_inch', size: Size(1024, 1366), safeArea: safeArea);

  static const Device webLaptop =
      Device(name: 'web_laptop', size: Size(1366, 768), safeArea: safeArea);

  static const Device webDesktop =
      Device(name: 'web_desktop', size: Size(1920, 1080), safeArea: safeArea);
}

extension DeviceExtensions on Device {
  Device landscape() {
    if (size.width > size.height) {
      return this;
    }
    return copyWith(
        name: '${name}_landscape', size: Size(size.height, size.width));
  }
}
