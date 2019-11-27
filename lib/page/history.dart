import 'package:flutter/material.dart';

import 'package:dataly/data/app_state.dart';

import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final dateFormat = DateFormat('MMM dd, yyyy');

  void removeItem(BuildContext context, int index) {
    final appState = Provider.of<AppState>(context);
    final entry = appState.history[index];
    AnimatedList.of(context).removeItem(
      index,
      (context, animation) => buildItem(context, index, animation),
      duration: Duration.zero,
    );
    appState.removeFromHistory(index);

    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Entry deleted'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          appState.addToHistory(entry.data, entry.date, index);
          AnimatedList.of(context).insertItem(index);
        },
      ),
    ));
  }

  Widget buildItem(BuildContext context, int index, Animation<double> animation) {
    final entry = Provider.of<AppState>(context).history[index];
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1,
      child: Dismissible(
        key: ValueKey(entry.date.millisecondsSinceEpoch),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => this.removeItem(context, index),
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: Icon(
              FontAwesomeIcons.trash,
              color: Colors.white,
            ),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            child: Text('${(entry.data.percent * 100).toInt()}%'),
          ),
          title: Text('${dateFormat.format(entry.date)}'),
          subtitle: Text('${entry.data.usage}'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: AnimatedList(
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) =>
            buildItem(context, index, animation.drive(CurveTween(curve: Curves.easeOutCubic))),
      ),
    );
  }
}
