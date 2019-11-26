import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dataly/widget/loading_sheet.dart';
import 'package:dataly/data/app_state.dart';
import 'package:dataly/widget/app_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sms_maintained/sms.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  SmsSender smsSender;
  Animation<double> rotation;
  AnimationController rotationController;
  bool hasFloatingButton = true;

  @override
  void initState() {
    super.initState();
    smsSender = SmsSender();

    rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && hasFloatingButton) rotationController.forward(from: 0);
      });
    rotation = rotationController.drive(CurveTween(curve: Curves.easeInOutBack));
  }

  @override
  void dispose() {
    rotationController.dispose();
    super.dispose();
  }

  Future<void> sendRequest(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    if (appState.updating != null && !appState.updating.isCompleted) appState.updating.complete(UpdateStatus.CANCELLED);

    return Future.wait([
      smsSender.sendSms(appState.carrier.smsMessage),
      Future.delayed(Duration(milliseconds: 200)),
    ])
      ..then((_) async {
        PersistentBottomSheetController controller;
        (appState.updating = Completer()).future.whenComplete(() async {
          if (controller != null) controller.close();
        });
        await Future.delayed(Duration(milliseconds: 600));

        controller = Scaffold.of(context).showBottomSheet(
          (context) => BottomSheet(
            onClosing: () {},
            builder: (context) => LoadingSheet(
              title: const Text('Waiting for SMS response...'),
              onHide: () {
                controller.close();
                appState.updating.complete(UpdateStatus.CANCELLED_BY_USER);
              },
            ),
          ),
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dataly'),
      ),
      drawer: AppDrawer(),
      floatingActionButton: FutureBuilder<UpdateStatus>(
          future: appState.updating != null ? appState.updating.future : Future.value(),
          builder: (context, snapshot) {
            hasFloatingButton = snapshot.connectionState == ConnectionState.done;
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 600),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeOutBack,
              transitionBuilder: (child, animation) => ScaleTransition(
                child: child,
                scale: animation,
              ),
              child: hasFloatingButton
                  ? FloatingActionButton(
                      child: RotationTransition(
                        turns: rotation,
                        child: Icon(
                          Icons.refresh,
                          size: 40,
                        ),
                      ),
                      onPressed: () {
                        rotationController.forward(from: 0);
                        this.sendRequest(context);
                      },
                    )
                  : SizedBox(),
            );
          }),
      body: Builder(
        builder: (context) {
          return !appState.hasDataUsage
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: double.infinity),
                    Text(
                      'No data found',
                      style: theme.textTheme.display1,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Icon(
                        FontAwesomeIcons.timesCircle,
                        size: 140,
                        color: (theme.brightness == Brightness.light ? Colors.black : Colors.white).withOpacity(0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(64, 8, 64, 0),
                      child: Text(
                        'Select your carrier in the left drawer and then press the refresh button below.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                )
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
                );
        },
      ),
    );
  }
}
