library parallax_image;

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

class ParallaxImage extends StatelessWidget {
  ParallaxImage({
    Key key,
    @required this.image,
    @required this.controller,
    @required this.size,
    this.color,
    this.child,
  })
      : super(key: key);
  final ImageProvider image;
  final ScrollController controller;
  final double size;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final constraints = (controller.position.axis == Axis.vertical)
        ? new BoxConstraints(minHeight: size)
        : new BoxConstraints(minWidth: size);
    return new RepaintBoundary(
      child: new ConstrainedBox(
        constraints: constraints,
        child: new _Parallax(
          image: image,
          controller: controller,
          child: child,
          screenSize: media.size,
        ),
      ),
    );
  }
}

class _Parallax extends SingleChildRenderObjectWidget {
  _Parallax({
    Key key,
    @required this.image,
    @required this.controller,
    @required this.screenSize,
    this.color,
    Widget child,
  })
      : super(key: key, child: child);
  final ImageProvider image;
  final ScrollController controller;
  final Size screenSize;
  final Color color;

  @override
  _RenderParallax createRenderObject(BuildContext context) {
    return new _RenderParallax(
      controller: controller,
      image: image,
      screenSize: screenSize,
    );
  }
}

class _RenderParallax extends RenderProxyBox {
  _RenderParallax({
    @required ScrollController controller,
    @required ImageProvider image,
    @required Size screenSize,
    Color color,
    ImageConfiguration configuration: ImageConfiguration.empty,
    RenderBox child,
  })
      : _image = image,
        _controller = controller,
        _screenSize = screenSize,
        _color = color,
        _configuration = configuration,
        super(child);

  ImageProvider _image;
  ScrollController _controller;
  Size _screenSize;
  Color _color;
  ImageConfiguration _configuration;
  Offset _position;
  BoxPainter _painter;

  ImageConfiguration get configuration => _configuration;

  Decoration get decoration {
    if (_decoration != null) return _decoration;

    // 0.5 => 0.0, 0.0 => -0.5 => 1.0 => 0.5
    final dy = _position.dy / _screenSize.height - 0.5;
    final alignment =
        Alignment.center.add(new Alignment(0.0, dy.clamp(-1.0, 1.0)));
    _decoration = new BoxDecoration(
      color: _color,
      image: new DecorationImage(
        alignment: alignment,
        image: _image,
        fit: fit,
      ),
    );
    return _decoration;
  }

  Decoration _decoration;

  BoxFit get fit {
    return (_controller.position.axis == Axis.vertical)
        ? BoxFit.fitWidth
        : BoxFit.fitHeight;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _controller.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _painter?.dispose();
    _painter = null;
    _controller.removeListener(markNeedsPaint);
    super.detach();
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(size.width != null);
    assert(size.height != null);
    var pos = localToGlobal(new Offset(0.0, 0.0));
    if (_position != pos) {
      _painter?.dispose();
      _painter = null;
      _decoration = null;
      _position = pos;
    }
    _painter ??= decoration.createBoxPainter(markNeedsPaint);
    final ImageConfiguration filledConfiguration =
        configuration.copyWith(size: size);
    int debugSaveCount;
    assert(() {
      debugSaveCount = context.canvas.getSaveCount();
      return true;
    }());
    _painter.paint(context.canvas, offset, filledConfiguration);
    assert(() {
      if (debugSaveCount != context.canvas.getSaveCount()) {
        throw new FlutterError(
            '${decoration.runtimeType} painter had mismatching save and restore calls.\n'
            'Before painting the decoration, the canvas save count was $debugSaveCount. '
            'After painting it, the canvas save count was ${context.canvas.getSaveCount()}. '
            'Every call to save() or saveLayer() must be matched by a call to restore().\n'
            'The decoration was:\n'
            '  $decoration\n'
            'The painter was:\n'
            '  $_painter');
      }
      return true;
    }());
    if (decoration.isComplex) context.setIsComplexHint();
    super.paint(context, offset);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(_decoration.toDiagnosticsNode(name: 'decoration'));
    description.add(new DiagnosticsProperty<ImageConfiguration>(
        'configuration', configuration));
  }
}
