//
// Level class for the math additions tasks
//

import 'dart:core';
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../core/level.dart';

/// Level class
class Level extends LevelBlueprint {
  /// callback to generator function, which should return the list of generated values for task and solution
  List<int> Function() onGenerate;

  /// callback to check the submission
  bool Function(List generated, List filled) onCheck;

  /// Collection of masks to be applied onto task
  ///
  /// Capital letter (e.g. Z in x+y=Z) means input place => x+y=?
  /// Small letters (x, y, in x+y=Z) means visible number
  /// If there are more than 1 mask, one of them is selected during the task generation
  List<String> masks;

  /// Declared range limit on generated values - used in unit tests
  List<int> valueRange;

  /// Human description
  String description;

  /// Printable example
  String example;

  /// Generated values typically x,y,w,z
  List<int> solution;

  /// Selected mask index for UI
  int selectedQuestionMaskID = 0;

  /// Selected mask for UI
  String get selectedQuestionMask => masks[selectedQuestionMaskID];

  /// Constructor
  Level(
      {@required index,
      xid,
      @required this.onGenerate,
      this.onCheck,
      this.masks,
      @required this.valueRange,
      this.description,
      this.example})
      : super(index: index);

  /// Cloning method
  Level clone() {
    return new Level(
        index: this.index,
        xid: this.xid,
        onGenerate: this.onGenerate,
        onCheck: this.onCheck,
        masks: this.masks,
        valueRange: this.valueRange,
        description: this.description,
        example: this.example);
  }

  /// random generator
  static Random rnd = Random();

  /// Generate solution and choose mask
  @override
  void generate() {
    solution = onGenerate();
    selectedQuestionMaskID = rnd.nextInt(masks.length);
  }

  @override
  String toString() =>
      "level: $index - $solution - ${masks[selectedQuestionMaskID]}";
}
