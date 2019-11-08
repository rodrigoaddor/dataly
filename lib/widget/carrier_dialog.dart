import 'package:dataly/data/app_state.dart';
import 'package:dataly/data/message_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CarrierDialog extends StatefulWidget {
  @override
  CarrierDialogState createState() => CarrierDialogState();
}

class CarrierDialogState extends State<CarrierDialog> {
  Widget generateCarrierTile(BuildContext context, Carrier carrier) {
    final appState = Provider.of<AppState>(context);
    final isImplemented = parsers.containsKey(carrier);
    final tile = RadioListTile<Carrier>(
      value: carrier,
      title: Text(carrier.toString().split('.')[1]),
      onChanged: isImplemented ? (carrier) => appState.carrier = carrier : null,
      groupValue: appState.carrier,
    );

    return isImplemented
        ? tile
        : Tooltip(
            child: tile,
            message: 'Message handling not implemented',
          );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Change Carrier'),
        contentPadding: EdgeInsets.fromLTRB(8, 20, 8, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Carrier.values.map((carrier) => generateCarrierTile(context, carrier)).toList(growable: false),
        ),
        actions: [
          FlatButton(
            child: const Text('Done'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
}
