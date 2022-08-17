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

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(title: new Text(title)),
      body: new Column(
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.all(20.0),
            child: new Text(
              'Horizontal scroll parallax',
              style: theme.textTheme.titleMedium, //.title / harfang
            ),
          ),
          new Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            constraints: const BoxConstraints(maxHeight: 200.0),
            child: new ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7, // null safety  / harfang
              itemBuilder: _buildHorizontalChild,
            ),
          ),
          new Container(
            padding: const EdgeInsets.all(20.0),
            child: new Text(
              'Vertical scroll parallax',
              style: theme.textTheme.titleMedium, //.title / harfang
            ),
          ),
          new Expanded(
            child: new ListView.builder(
              itemCount: 7, // null safety / harfang
              itemBuilder: _buildVerticalChild,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVerticalChild(BuildContext context, int index) {
    index++;
    if (index > 7) return Container(); //  null safety / harfang
    return new Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: new GestureDetector(
        onTap: () {
          print('Tapped $index');
        },
        child: new ParallaxImage(
          extent: 150.0,
          image: new ExactAssetImage(
            'images/img$index.jpg',
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalChild(BuildContext context, int index) {
    index++;
    if (index > 7) return Container(); // null safety safety

    return new Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: new ParallaxImage(
        extent: 100.0,
        image: new ExactAssetImage(
          'images/img$index.jpg',
        ),
      ),
    );
  }
}
