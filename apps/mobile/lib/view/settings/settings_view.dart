import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/session_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Debug section
          _SectionHeader(title: l10n.debugSection),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: Text(l10n.debugConsole),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/debug'),
          ),
          SwitchListTile(
            title: Text(l10n.simulateDeviceMode),
            subtitle: Text(l10n.simulateDeviceModeDescription),
            secondary: const Icon(Icons.devices_other),
            value: session.isFakeMode,
            onChanged: session.enableFakeMode,
          ),
          const Divider(),
          // About section using AboutListTile
          _SectionHeader(title: l10n.aboutSection),
          AboutListTile(
            icon: const Icon(Icons.info_outline),
            applicationName: l10n.aboutAppTitle,
            applicationVersion: 'v1.0.0',
            applicationLegalese: '© 2026 Osmo Controller',
            aboutBoxChildren: [
              const SizedBox(height: 16),
              Text(l10n.aboutAppSubtitle),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}