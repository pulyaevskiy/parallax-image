# parallax_image

Parallax image widget for Flutter.

![demo.gif](demo.gif)

## Installation

Add dependency to your `pubspec.yaml`:

```yaml
dependencies:
  parallax_image: ^0.1.0
```

## Usage

`ParallaxImage` can be used with any `Scrollable` (`ListView` for instance)
and only depends on an instance of `ScrollController` attached to that 
scrollable.

```dart
class MyWidget extends StatefulWidget {
    @override
    MyWidgetState createState() => new MyWidgetState();
}

class MyWidgetState extends State<MyWidget> {
    final ScrollController _controller = new ScrollController();
    @override
    Widget build(BuildContext context) {
        return new ListView(
            controller: _controller,
            children: <Widget>[
                new ParallaxImage(
                    controller: _controller,
                    image: new AssetImage('images/some.jpg'),
                    // Extent of this widget in scroll direction.
                    // In this case it is vertical scroll so it defines 
                    // the height of this widget. 
                    // The image is scaled with BoxFit.fitWidth which makes it
                    // occupy full width of this widget.
                    // Scaled image should normally have height greater 
                    // than this value to allow for parallax effect to be
                    // visible.
                    extent: 100.0,
                ),
                // ...add more list items
            ]
        );
    }
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][issue_tracker].

[issue_tracker]: https://github.com/pulyaevskiy/parallax-image/issues
