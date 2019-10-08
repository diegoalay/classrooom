import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PageIndicator extends StatelessWidget {
  final int index, totalOfPages;
  final BuildContext context;

  const PageIndicator({
    @required this.index,
    @required this.totalOfPages,
    @required this.context,
  });

  List<Widget> _renderIndicators() {
    List<Widget> indicators = List<Widget>();
    for (int i = 0; i < this.totalOfPages; i++) {
      IconData icon = FontAwesomeIcons.circle;
      Color color = Colors.white;
      if (i == (index - 1)) {
        icon = FontAwesomeIcons.solidCircle;
        color = Theme.of(this.context).primaryColor;
      } 
      indicators.add(
        Container(
          margin: EdgeInsets.all(8),
          child: Icon(
            icon,
            color: color,
            size: 12,
          ),
        ),
      );
    }
    return indicators;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _renderIndicators(),
    );
  }
}