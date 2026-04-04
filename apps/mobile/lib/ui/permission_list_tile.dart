import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/permission_service.dart';

/// A list tile widget displaying a single permission group with its status and action button.
class PermissionListTile extends StatelessWidget {
  final PermissionGroupStatus permissionStatus;
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;

  const PermissionListTile({
    super.key,
    required this.permissionStatus,
    required this.onRequest,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: _buildStatusIcon(),
      title: Text(_getPermissionName(l10n)),
      subtitle: Text(_getPermissionDescription(l10n)),
      trailing: _buildActionButton(l10n),
    );
  }

  Widget _buildStatusIcon() {
    late Color color;
    late IconData iconData;

    switch (permissionStatus.status) {
      case PermissionStatusType.granted:
        color = Colors.green;
        iconData = Icons.check_circle;
        break;
      case PermissionStatusType.denied:
        color = Colors.orange;
        iconData = Icons.error_outline;
        break;
      case PermissionStatusType.permanentlyDenied:
        color = Colors.red;
        iconData = Icons.cancel;
        break;
    }

    return Icon(iconData, color: color);
  }

  Widget? _buildActionButton(AppLocalizations l10n) {
    if (permissionStatus.isGranted) {
      return null;
    }

    if (permissionStatus.isPermanentlyDenied) {
      return TextButton(
        onPressed: onOpenSettings,
        child: Text(l10n.permissionOpenSettings),
      );
    }

    return TextButton(
      onPressed: onRequest,
      child: Text(l10n.permissionRequest),
    );
  }

  String _getPermissionName(AppLocalizations l10n) {
    return switch (permissionStatus.name) {
      'permissionBluetooth' => l10n.permissionBluetooth,
      'permissionLocation' => l10n.permissionLocation,
      'permissionLocationAlways' => l10n.permissionLocationAlways,
      'permissionNotification' => l10n.permissionNotification,
      _ => permissionStatus.name,
    };
  }

  String _getPermissionDescription(AppLocalizations l10n) {
    return switch (permissionStatus.description) {
      'permissionBluetoothDesc' => l10n.permissionBluetoothDesc,
      'permissionLocationDesc' => l10n.permissionLocationDesc,
      'permissionLocationAlwaysDesc' => l10n.permissionLocationAlwaysDesc,
      'permissionNotificationDesc' => l10n.permissionNotificationDesc,
      _ => permissionStatus.description,
    };
  }
}

/// A section displaying all required permissions with their status.
class PermissionSection extends StatelessWidget {
  const PermissionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final permissionService = context.watch<PermissionService>();

    if (!permissionService.isInitialized) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final permissions = permissionService.permissionStatuses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.permissionSection),
        ...permissions.map((status) => PermissionListTile(
              permissionStatus: status,
              onRequest: () => _handleRequest(context, permissionService, status),
              onOpenSettings: () => permissionService.openSettings(),
            )),
        if (!permissionService.allGranted)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.permissionAllRequired,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleRequest(
    BuildContext context,
    PermissionService service,
    PermissionGroupStatus status,
  ) async {
    await service.requestPermission(status);
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