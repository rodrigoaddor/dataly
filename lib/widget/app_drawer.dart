import 'package:flutter/material.dart';

import 'package:dataly/data/app_state.dart';
import 'package:dataly/widget/carrier_dialog.dart';
import 'package:dataly/widget/boxed_text.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Widget buildHeader(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd');

    return SizedBox(
      height: 100,
      child: DrawerHeader(
        padding: EdgeInsets.only(left: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoxedText(
              height: 36,
              child: Text(
                appState.carrier != null ? appState.carrier.name : 'Unknown Carrier',
                style: theme.textTheme.title,
              ),
            ),
            BoxedText(
              height: 48,
              child: appState.hasDataUsage
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${appState.data?.limit} plan',
                        ),
                        Text(
                          'Resets on ${dateFormat.format(appState.data?.reset ?? DateTime.now())}',
                        ),
                      ],
                    )
                  : Padding(
                    padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'No data usage info',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Drawer(
      child: ListView(
        children: [
          buildHeader(context),
          ListTile(
            title: const Text('Carrier'),
            leading: Icon(FontAwesomeIcons.phoneAlt),
            onTap: () => showDialog(context: context, builder: (context) => CarrierDialog()),
          ),
          ListTile(
            title: const Text('Usage History'),
            leading: Icon(FontAwesomeIcons.history),
          ),
          Divider(),
          SizedBox(
            height: 28,
            child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Settings',
                    style: Theme.of(context).textTheme.body1,
                  ),
                )),
          ),
          SwitchListTile(
            title: const Text('Dark Theme'),
            secondary:
                Icon(appState.theme == ThemeMode.dark ? FontAwesomeIcons.solidLightbulb : FontAwesomeIcons.lightbulb),
            value: appState.theme == ThemeMode.dark,
            onChanged: (dark) => appState.theme = dark ? ThemeMode.dark : ThemeMode.light,
          ),
        ],
      ),
    );
  }
}
