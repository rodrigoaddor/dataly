import 'package:flutter/material.dart';

import 'package:dataly/data/app_state.dart';
import 'package:dataly/widget/carrier_dialog.dart';

import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                children: [if(appState.carrier != null) Text(appState.carrier.name)],
              ),
            ),
            ListTile(
              title: const Text('Carrier'),
              leading: Icon(FontAwesomeIcons.phoneAlt),
              onTap: () => showDialog(context: context, builder: (context) => CarrierDialog()),
            ),
            ListTile(
              title: const Text('Settings'),
              leading: Icon(FontAwesomeIcons.cog),
            )
          ],
        ),
      );
  }
}
