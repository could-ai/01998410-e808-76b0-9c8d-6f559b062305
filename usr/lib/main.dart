import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screensaver App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ScreensaverPage(),
    );
  }
}

enum ShapeType { ellipse, rectangle }

enum MovementType { stationary, smooth, random }

class Shape {
  ShapeType type;
  Color color;
  Rect rect;
  double dx;
  double dy;

  Shape({
    required this.type,
    required this.color,
    required this.rect,
    required this.dx,
    required this.dy,
  });
}

class ScreensaverPage extends StatefulWidget {
  const ScreensaverPage({super.key});

  @override
  State<ScreensaverPage> createState() => _ScreensaverPageState();
}

class _ScreensaverPageState extends State<ScreensaverPage>
    with SingleTickerProviderStateMixin {
  ShapeType _selectedShape = ShapeType.ellipse;
  Color _selectedColor = Colors.blue;
  MovementType _selectedMovement = MovementType.smooth;
  List<Shape> _shapes = [];
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateShapes);
    _controller!.repeat();
    // Defer shape initialization until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeShapes();
    });
  }

  void _initializeShapes() {
    final random = Random();
    final size = MediaQuery.of(context).size;
    _shapes = List.generate(20, (index) {
      final shapeType = _selectedShape;
      final color = Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        1,
      );
      final rect = Rect.fromLTWH(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
        50,
        50,
      );
      return Shape(
        type: shapeType,
        color: color,
        rect: rect,
        dx: (random.nextDouble() - 0.5) * 4,
        dy: (random.nextDouble() - 0.5) * 4,
      );
    });
    setState(() {});
  }

  void _updateShapes() {
    if (_selectedMovement == MovementType.stationary) return;

    final size = MediaQuery.of(context).size;
    final random = Random();

    setState(() {
      for (var shape in _shapes) {
        if (_selectedMovement == MovementType.smooth) {
          var newRect = shape.rect.translate(shape.dx, shape.dy);
          if (newRect.left < 0 || newRect.right > size.width) {
            shape.dx *= -1;
          }
          if (newRect.top < 0 || newRect.bottom > size.height) {
            shape.dy *= -1;
          }
          shape.rect = shape.rect.translate(shape.dx, shape.dy);
        } else if (_selectedMovement == MovementType.random) {
          shape.rect = shape.rect.translate(
            (random.nextDouble() - 0.5) * 10,
            (random.nextDouble() - 0.5) * 10,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(_updateShapes);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screensaver'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShapeDropdown(),
                _buildColorDropdown(),
                _buildMovementDropdown(),
              ],
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: ShapePainter(shapes: _shapes),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  DropdownButton<ShapeType> _buildShapeDropdown() {
    return DropdownButton<ShapeType>(
      value: _selectedShape,
      onChanged: (ShapeType? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedShape = newValue;
            _updateShapeTypes();
          });
        }
      },
      items: ShapeType.values.map((ShapeType shape) {
        return DropdownMenuItem<ShapeType>(
          value: shape,
          child: Text(shape.toString().split('.').last),
        );
      }).toList(),
    );
  }

  void _updateShapeTypes() {
    for (var shape in _shapes) {
      shape.type = _selectedShape;
    }
  }

  DropdownButton<Color> _buildColorDropdown() {
    return DropdownButton<Color>(
      value: _selectedColor,
      onChanged: (Color? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedColor = newValue;
            _updateShapeColors();
          });
        }
      },
      items: [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
      ].map((Color color) {
        return DropdownMenuItem<Color>(
          value: color,
          child: Text(color.toString()),
        );
      }).toList(),
    );
  }

  void _updateShapeColors() {
    for (var shape in _shapes) {
      shape.color = _selectedColor;
    }
  }

  DropdownButton<MovementType> _buildMovementDropdown() {
    return DropdownButton<MovementType>(
      value: _selectedMovement,
      onChanged: (MovementType? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedMovement = newValue;
          });
        }
      },
      items: MovementType.values.map((MovementType movement) {
        return DropdownMenuItem<MovementType>(
          value: movement,
          child: Text(movement.toString().split('.').last),
        );
      }).toList(),
    );
  }
}

class ShapePainter extends CustomPainter {
  final List<Shape> shapes;

  ShapePainter({required this.shapes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var shape in shapes) {
      paint.color = shape.color;
      if (shape.type == ShapeType.rectangle) {
        canvas.drawRect(shape.rect, paint);
      } else {
        canvas.drawOval(shape.rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
