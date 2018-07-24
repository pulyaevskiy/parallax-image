// Copyright (c) 2018, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// [ParallaxImage] paints an image and moves it at a slower speed than the main
/// scrolling content.
library parallax_image;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A widget that paints an image and moves it at a slower speed than the main
/// scrolling content.
///
/// Image is rendered in a box with specified [extent] in the scroll direction.
///
/// If scroll [controller] is provided then this widget reacts to scrolling
/// updates in [ScrollController.position] which assumes that controller is
/// attached to only one [Scrollable]. Otherwise this widget looks for
/// nearest [Scrollable] ancestor and subscribes to scrolling updates on it.
///
/// When scroll direction is [Axis.vertical] the image is scaled to fit width
/// ([BoxFit.fitWidth]) of parent widget. For [Axis.horizontal] scroll direction
/// the image is scaled to fit height ([BoxFit.fitHeight]) of parent widget.
class ParallaxImage extends StatelessWidget {
  /// Creates new [ParallaxImage].
  ///
  /// [image] and [extent] arguments are required.
  ///
  /// If scroll [controller] is provided then created widget reacts to scrolling
  /// updates in [ScrollController.position] which assumes that controller is
  /// attached to only one [Scrollable]. Otherwise created widget looks for
  /// nearest [Scrollable] ancestor and subscribes to scrolling updates on it.
  ParallaxImage({
    Key key,
    @required this.image,
    @required this.extent,
    this.controller,
    this.color,
    this.child,
  }) : super(key: key);

  /// The image to paint.
  final ImageProvider image;

  /// Scroll controller which determines scroll direction and notifies this
  /// widget of scroll position changes.
  ///
  /// If `null` then this widget uses nearest [Scrollable] ancestor to determine
  /// scroll direction and listen for scroll position changes.
  final ScrollController controller;

  /// Extent of this widget in scroll direction.
  ///
  /// If scroll direction is [Axis.vertical] it is the height of this widget,
  /// if scroll direction is [Axis.horizontal] it is the width.
  final double extent;

  /// Optinal color to paint behind the [image].
  final Color color;

  /// The optional child of this widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scrollPosition = (controller != null)
        ? controller.position
        : Scrollable.of(context).position;
    final constraints = (scrollPosition.axis == Axis.vertical)
        ? new BoxConstraints(minHeight: extent)
        : new BoxConstraints(minWidth: extent);
    return new RepaintBoundary(
      child: new ConstrainedBox(
        constraints: constraints,
        child: new _Parallax(
          image: image,
          scrollPosition: scrollPosition,
          child: child,
          screenSize: media.size,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);

    description.add(new DoubleProperty('extent', extent));
    description.add(new DiagnosticsProperty<ImageProvider>('image', image));
    description.add(new DiagnosticsProperty<Color>('color', color));
  }
}

class _Parallax extends SingleChildRenderObjectWidget {
  _Parallax({
    Key key,
    @required this.image,
    @required this.scrollPosition,
    @required this.screenSize,
    this.color,
    Widget child,
  }) : super(key: key, child: child);
  final ImageProvider image;
  final ScrollPosition scrollPosition;
  final Size screenSize;
  final Color color;

  @override
  _RenderParallax createRenderObject(BuildContext context) {
    return new _RenderParallax(
      scrollPosition: scrollPosition,
      image: image,
      screenSize: screenSize,
      color: color,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderParallax renderObject) {
    renderObject
      ..image = image
      ..scrollPosition = scrollPosition
      ..screenSize = screenSize
      ..color = color;
  }
}

class _RenderParallax extends RenderProxyBox {
  _RenderParallax({
    @required ScrollPosition scrollPosition,
    @required ImageProvider image,
    @required Size screenSize,
    Color color,
    ImageConfiguration configuration: ImageConfiguration.empty,
    RenderBox child,
  })  : _image = image,
        _scrollPosition = scrollPosition,
        _screenSize = screenSize,
        _color = color,
        _configuration = configuration,
        super(child);

  ImageProvider _image;
  ScrollPosition _scrollPosition;
  Size _screenSize;
  Color _color;
  ImageConfiguration _configuration;
  Offset _position;
  BoxPainter _painter;

  set image(ImageProvider value) {
    if (value == _image) return;
    _image = value;
    _painter?.dispose();
    _painter = null;
    _decoration = null;
    markNeedsPaint();
  }

  set scrollPosition(ScrollPosition value) {
    if (value == _scrollPosition) return;
    if (attached) _scrollPosition.removeListener(markNeedsPaint);
    _scrollPosition = value;
    if (attached) _scrollPosition.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  set screenSize(Size value) {
    if (value == _screenSize) return;
    _screenSize = value;
    markNeedsPaint();
  }

  set color(Color value) {
    if (value == _color) return;
    _color = value;
    _painter?.dispose();
    _painter = null;
    _decoration = null;
    markNeedsPaint();
  }

  ImageConfiguration get configuration => _configuration;

  Decoration get decoration {
    if (_decoration != null) return _decoration;

    /// Algorithm here uses only devices screen size and current
    /// global position of this image.
    ///
    /// We calculate absolute position of this image as a fraction of screen size
    /// in range `0.0...1.0`, where `0.0` means the image is at the top of the
    /// screen and `1.0` means it's at the bottom.
    ///
    /// When image is centered on the screen (position `0.5`) it should also
    /// have centered alignment ([Alignment.center]) within it's render box.
    ///
    /// When image moves in any direction from the screen center we adjust
    /// its alignment by the distance traveled as a fraction of screen
    /// size.
    ///
    /// So alignment of image at the screen center would be equal to `0.0`
    /// in the scroll direction. For an image with screen position `0.0` its
    /// alignment would be `-0.5` because it traveled half of the screen size.

    // TODO: Might be a good idea to provide a way to customize this logic.
    Alignment alignment;
    if (_scrollPosition.axis == Axis.vertical) {
      double value = (_position.dy / _screenSize.height - 0.5).clamp(-1.0, 1.0);
      alignment = new Alignment(0.0, value);
    } else {
      double value = (_position.dx / _screenSize.width - 0.5).clamp(-1.0, 1.0);
      alignment = new Alignment(value, 0.0);
    }

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
    return (_scrollPosition.axis == Axis.vertical)
        ? BoxFit.fitWidth
        : BoxFit.fitHeight;
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scrollPosition.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _painter?.dispose();
    _painter = null;
    _scrollPosition.removeListener(markNeedsPaint);
    super.detach();
    markNeedsPaint();
  }

  @protected
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(size.width != null);
    assert(size.height != null);
    // We use center of the widget's render box as a reference point.
    var pos = localToGlobal(new Offset(size.width / 2, size.height / 2));
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

    description.add(new DiagnosticsProperty<ScrollPosition>(
        'scrollPosition', _scrollPosition));
    description.add(new DiagnosticsProperty<Size>('screenSize', _screenSize));
    description.add(_decoration.toDiagnosticsNode(name: 'decoration'));
    description.add(new DiagnosticsProperty<ImageConfiguration>(
        'configuration', configuration));
  }
}
