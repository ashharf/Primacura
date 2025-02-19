import 'dart:ui';
import 'package:flutter/material.dart';

class WeightedScrollPhysics extends BouncingScrollPhysics {
  final double weight;

  const WeightedScrollPhysics({this.weight = 1.0, super.parent});

  @override
  WeightedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return WeightedScrollPhysics(
      weight: weight,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Modify the offset by the weight
    return super.applyPhysicsToUserOffset(position, offset * weight);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Allow boundary conditions to scale with weight if necessary
    return super.applyBoundaryConditions(position, value);
  }
}

class BouncyScrollBehavior extends MaterialScrollBehavior {
  final double scrollWeight;

  const BouncyScrollBehavior({this.scrollWeight = 1.0});

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return WeightedScrollPhysics(weight: scrollWeight); // Apply weighted bouncy effect
  }
}
