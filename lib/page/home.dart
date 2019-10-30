import 'package:dataly/main.dart';
import 'package:dataly/widget/input_dialog.dart';
import 'package:flutter/material.dart';

import 'package:dataly/data/data_usage.dart';

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
    final dataUsage = Provider.of<DataUsage>(context);

    print(dataUsage.reset.toIso8601String());
    print(dataUsage.start.toIso8601String());
    print(DateTime.now().toIso8601String());

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

          if (result != null && result.length > 0) handleMessage(result);
        },
        child: FloatingActionButton(
          onPressed: this.sendRequest,
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          CircularPercentIndicator(
            percent: dataUsage.percent,
            radius: 256,
            lineWidth: 16,
            animation: true,
            animationDuration: 300,
            animateFromLastPercent: true,
            center: Text('${dataUsage.usage} of ${dataUsage.limit}'),
          ),
          CircularPercentIndicator(
            percent: dataUsage.datePercent,
            radius: 220,
            lineWidth: 14,
          ),
        ],
      ),
    );
  }
}
