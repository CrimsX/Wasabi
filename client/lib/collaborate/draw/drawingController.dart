import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter/material.dart';

class CustomDrawingController extends DrawingController {
  VoidCallback? onClear;
  VoidCallback? onUndo;
  VoidCallback? onRedo;

  @override
  void clear() {
    super.clear();
    if (onClear != null) {
      onClear!();
    }
  }

  @override
  void undo() {
    super.undo();
    if (onUndo != null) {
      onUndo!();
    }
  }

  @override
  void redo() {
    super.redo();
    if (onRedo != null) {
      onRedo!();
    }
  }
}
