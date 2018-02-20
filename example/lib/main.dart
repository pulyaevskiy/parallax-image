import 'package:flutter/material.dart';
import 'package:parallax_image/parallax_image.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Parallax Image Demo',
      theme: new ThemeData(primarySwatch: Colors.blueGrey),
      home: new MyHomePage(title: 'Parallax Image Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _verticalController = new ScrollController();
  final ScrollController _horizontalController = new ScrollController();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(title: new Text(widget.title)),
      body: new Column(
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.all(20.0),
            child: new Text(
              'Horizontal scroll parallax',
              style: theme.textTheme.title,
            ),
          ),
          new Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            constraints: const BoxConstraints(maxHeight: 200.0),
            child: new ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: _buildHorizontalChild,
              controller: _horizontalController,
            ),
          ),
          new Container(
            padding: const EdgeInsets.all(20.0),
            child: new Text(
              'Vertical scroll parallax',
              style: theme.textTheme.title,
            ),
          ),
          new Expanded(
            child: new ListView.builder(
              itemBuilder: _buildVerticalChild,
              controller: _verticalController,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVerticalChild(BuildContext context, int index) {
    index++;
    if (index > 7) return null;
    return new Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: new ParallaxImage(
        extent: 150.0,
        controller: _verticalController,
        image: new ExactAssetImage(
          'images/img$index.jpg',
        ),
      ),
    );
  }

  Widget _buildHorizontalChild(BuildContext context, int index) {
    index++;
    if (index > 7) return null;
    return new Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: new ParallaxImage(
        extent: 100.0,
        controller: _horizontalController,
        image: new ExactAssetImage(
          'images/img$index.jpg',
        ),
      ),
    );
  }
}
