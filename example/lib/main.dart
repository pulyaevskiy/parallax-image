import 'package:flutter/material.dart';
import 'package:parallax_image/parallax_image.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Parallax Image Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  final ScrollController _controller = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text(widget.title)),
      body: new ListView.builder(
        itemBuilder: _buildChild,
        controller: _controller,
      ),
    );
  }

  Widget _buildChild(BuildContext context, int index) {
    if (index >= 15) return null;
    index++;
    return new Padding(
      padding: const EdgeInsets.only(bottom: 1.0),
      child: new ParallaxImage(
        size: 150.0,
        controller: _controller,
        image: new ExactAssetImage(
          'images/Original-Star-Wars-Storyboard-Illustrations$index.jpg',
        ),
      ),
    );
  }
}
