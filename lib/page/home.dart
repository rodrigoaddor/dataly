import 'package:flutter/material.dart';

import 'package:dataly/data/app_state.dart';
import 'package:dataly/data/message_handler.dart';
import 'package:dataly/widget/input_dialog.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:sms_maintained/sms.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  SmsSender smsSender;
  SmsReceiver smsReceiver;

  @override
  void initState() {
    super.initState();
    smsSender = SmsSender();
    smsReceiver = SmsReceiver();
  }

  void sendRequest() {
    smsSender.sendSms(SmsMessage('4141', 'consumoweb'));
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dataly'),
      ),
      floatingActionButton: InkWell(
        onLongPress: () async {
          final result = await showDialog<String>(
            context: context,
            builder: (context) => InputDialog(
              title: 'Handle Message',
            ),
          );

          if (result != null && result.length > 0) {
            try {
              // TODO: Get carrier from user prefs
              appState.data = MessageHandler(carrier: Carrier.TIM).handle(result);
            } on FormatException catch (_) {}
          }
        },
        child: FloatingActionButton(
          onPressed: this.sendRequest,
        ),
      ),
      body: !appState.hasDataUsage
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
    );
  }
}
