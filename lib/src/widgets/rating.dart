import 'package:flutter/widgets.dart';

import 'package:rooktook/src/constants.dart';

class RatingWidget extends StatelessWidget {
  const RatingWidget({
    required this.rating,
    required this.deviation,
    this.provisional,
    this.style,
    super.key,
  });

  final num rating;
  final num deviation;
  final bool? provisional;

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${rating.round()}${provisional == true || deviation > kProvisionalDeviation ? '?' : ''}',
      style: style,
    );
  }
}
