import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dataly/data/app_state.dart';
import 'package:dataly/widget/app_drawer.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sms_maintained/sms.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  SmsSender smsSender;
  Animation<double> rotation;
  AnimationController rotationController;

  @override
  void initState() {
    super.initState();
    smsSender = SmsSender();
  }

  Future<void> sendRequest(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    if (appState.updating != null && !appState.updating.isCompleted) appState.updating.completeError('Cancelled');

    return smsSender.sendSms(appState.carrier.smsMessage)
      ..then((_) {
        final controller = Scaffold.of(context).showSnackBar(SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Waiting for response'),
              SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 3)),
            ],
          ),
          duration: Duration(hours: 1),
        ));
        (appState.updating = Completer()).future.whenComplete(() => controller.close());
      });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dataly'),
      ),
      drawer: AppDrawer(),
      body: Builder(
        builder: (context) {
          return RefreshIndicator(
            onRefresh: () => this.sendRequest(context),
            child: PageView(
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              children: [
                !appState.hasDataUsage
                    ? Text('No data found')
                    : Stack(
                        alignment: Alignment.center,
                        fit: StackFit.expand,
                        children: [
                          CircularPercentIndicator(
                            percent: appState.data.percent,
                            radius: 256,
                            lineWidth: 16,
                            animation: true,
                            animationDuration: 300,
                            animateFromLastPercent: true,
                            center: Text('${appState.data.usage} of ${appState.data.limit}'),
                          ),
                          CircularPercentIndicator(
                            percent: appState.data.datePercent,
                            radius: 220,
                            lineWidth: 14,
                          ),
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
