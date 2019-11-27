import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dataly/data/app_state.dart';
import 'package:dataly/page/history.dart';
import 'package:dataly/widget/carrier_dialog.dart';
import 'package:dataly/widget/boxed_text.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryPage()),
            ),
          ),
          Divider(),
          SizedBox(
            height: 32,
            child: Padding(
                padding: EdgeInsets.only(left: 16, bottom: 8),
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
          Divider(),
          ListTile(
            title: const Text('Export Data'),
            leading: Icon(FontAwesomeIcons.fileExport),
            onTap: () async {
              final path = '${(await getTemporaryDirectory()).path}/dataly.json';
              final file = File(path);
              file.writeAsString(jsonEncode(appState.toJSON()));
              FlutterShare.shareFile(
                title: 'Dataly Export',
                filePath: path,
              );
            },
          ),
          ListTile(
            title: const Text('Import Data'),
            leading: Icon(FontAwesomeIcons.fileImport),
            onTap: () async {
              final file = File(await FilePicker.getFilePath(type: FileType.ANY, fileExtension: 'json'));
              final data = jsonDecode(await file.readAsString());
              appState.updateFromJSON(data);
            },
          )
        ],
      ),
    );
  }
}
