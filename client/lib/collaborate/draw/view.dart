import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_drawing_board/paint_extension.dart';
import 'drawingController.dart';
import 'package:socket_io_client/socket_io_client.dart';

class DrawScreen extends StatefulWidget {
  Socket? socket;
  String username = '';
  DrawScreen({super.key, required this.username ,required this.socket});

  @override
  _DrawScreenState createState() => _DrawScreenState();
}

class _DrawScreenState extends State <DrawScreen> {
  final CustomDrawingController _drawingController = CustomDrawingController();
  int drawingBoardJSONLen = 0;
  dynamic test;
  String sender = "";
  Map<String, dynamic> next = {};
  Map<String, dynamic> prev = {};
  @override
  void initState() {
    super.initState();

    _drawingController.onClear = () {
      clearBoard();
      drawingBoardJSONLen = 0;
    };

    _drawingController.onUndo = () {
      undoBoard();
    };

    _drawingController.onRedo = () {
      redoBoard();
    };
    _connectSocket();
    widget.socket!.emit("joinwhiteboard");
  }

  _connectSocket() {
    widget.socket!.on('fetchlive', (data) => {
      print(data),
      _addToWhiteboard(data)
    });

    widget.socket!.on('clear', (data) => {
      receiveClear(data)
    });

    widget.socket!.on('undo', (data) => {
      receiveUndo(data)
    });

    widget.socket!.on('redo', (data) => {
      receiveRedo(data)
    });
  }

  _addToWhiteboard(draw) {
    processDrawType(draw['type'], draw);
    drawingBoardJSONLen = _drawingController.getJsonList().length;
  }

  processDrawType(type, draw) {
    if (type == "SimpleLine" || type == "Eraser") {
      List<dynamic> steps = draw['path']['steps'];
      steps.forEach((step) {
        step['x'] = step['x'].toDouble();
        step['y'] = step['y'].toDouble();
    });
      final double newStrokeWidth = draw['paint']['strokeWidth'].toDouble();
      draw['paint']['strokeWidth'] = newStrokeWidth;
      if (type == "SimpleLine") {
        _drawingController.addContents(<PaintContent>[SimpleLine.fromJson(draw)]);
      } else {
        _drawingController.addContents(<PaintContent>[Eraser.fromJson(draw)]);
        }
      } else if (type == "Circle") {
          final double centerDx = draw['center']['dx'].toDouble();
          final double centerDy = draw['center']['dy'].toDouble();
          final double startPointDx = draw['startPoint']['dx'].toDouble();
          final double startPointDy = draw['startPoint']['dy'].toDouble();
          final double endPointDx = draw['endPoint']['dx'].toDouble();
          final double endPointDy = draw['endPoint']['dy'].toDouble();
          final double strokeWidth = draw['paint']['strokeWidth'].toDouble();

          // Update the values in the original data
          draw['center']['dx'] = centerDx;
          draw['center']['dy'] = centerDy;
          draw['startPoint']['dx'] = startPointDx;
          draw['startPoint']['dy'] = startPointDy;
          draw['endPoint']['dx'] = endPointDx;
          draw['endPoint']['dy'] = endPointDy;
          draw['paint']['strokeWidth'] = strokeWidth;
          _drawingController.addContents(<PaintContent>[Circle.fromJson(draw)]);
      } else if (type == "Rectangle") {
        final double startPointDx = draw['startPoint']['dx'].toDouble();
        final double startPointDy = draw['startPoint']['dy'].toDouble();
        final double endPointDx = draw['endPoint']['dx'].toDouble();
        final double endPointDy = draw['endPoint']['dy'].toDouble();
        final double strokeWidth = draw['paint']['strokeWidth'].toDouble();

        // Update the values in the original data
        draw['startPoint']['dx'] = startPointDx;
        draw['startPoint']['dy'] = startPointDy;
        draw['endPoint']['dx'] = endPointDx;
        draw['endPoint']['dy'] = endPointDy;
        draw['paint']['strokeWidth'] = strokeWidth;
        _drawingController.addContents(<PaintContent>[Rectangle.fromJson(draw)]);
      } else if (type == "StraightLine") {
          // Convert dx, dy, and strokeWidth values to double
          final double startPointDx = draw['startPoint']['dx'].toDouble();
          final double startPointDy = draw['startPoint']['dy'].toDouble();
          final double endPointDx = draw['endPoint']['dx'].toDouble();
          final double endPointDy = draw['endPoint']['dy'].toDouble();
          final double strokeWidth = draw['paint']['strokeWidth'].toDouble();

          // Update the values in the original data
          draw['startPoint']['dx'] = startPointDx;
          draw['startPoint']['dy'] = startPointDy;
          draw['endPoint']['dx'] = endPointDx;
          draw['endPoint']['dy'] = endPointDy;
          draw['paint']['strokeWidth'] = strokeWidth;
          _drawingController.addContents(<PaintContent>[StraightLine.fromJson(draw)]);
      } else if (type == "SmoothLine") {
          for (var point in draw['points']) {
            point['dx'] = point['dx'].toDouble();
            point['dy'] = point['dy'].toDouble();
          }
          for (int i = 0; i < draw['strokeWidthList'].length; i++) {
            draw['strokeWidthList'][i] = draw['strokeWidthList'][i].toDouble();
          }
          final double strokeWidth = draw['paint']['strokeWidth'].toDouble();
          draw['paint']['strokeWidth'] = strokeWidth;
          _drawingController.addContents(<PaintContent>[SmoothLine.fromJson(draw)]);
      }
    }

  clearBoard() {
    if (sender == "") {
      widget.socket!.emit('clear', (widget.username));
    }
  }

  undoBoard() {
    if (sender == "") {
      widget.socket!.emit('undo', (widget.username));
    }
  }

  redoBoard() {
    if (sender == "") {
      widget.socket!.emit('redo', (widget.username));
    }
  }

  receiveClear(username) {
    sender = username;
    _drawingController.clear();
    sender = "";
  }

  receiveUndo(username) {
    sender = username;
    _drawingController.undo();
    sender = "";
  }

  receiveRedo(username) {
    sender = username;
    _drawingController.redo();
    sender = "";
  }

  Future<void> _getJsonList() async {
    int cur_len = _drawingController.getJsonList().length;
    if (drawingBoardJSONLen == cur_len) {
      return;
    }
    else {
      drawingBoardJSONLen = _drawingController.getJsonList().length;
      widget.socket!.emit('senddrawing', (_drawingController.getJsonList().last));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw'),
        backgroundColor: Colors.green,
      ),
      /*
      body: Center(
        child: Image.asset('assets/DrawingImage.webp'),
      ),
      */
      body: Listener(
        onPointerUp: (event) {
          _getJsonList();
        },

        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: DrawingBoard(
                    controller: _drawingController,
                    background: Container(
                      width: MediaQuery.of(context).size.width,
                      height: (MediaQuery.of(context).size.height),
                      color: Color.fromARGB(255, 232, 252, 209)
                      ),
                    showDefaultActions: true,
                    showDefaultTools: true,
                    boardPanEnabled: false,
                    boardScaleEnabled: false,
                    boardBoundaryMargin: EdgeInsets.all(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
