import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/session_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          const _SectionHeader(title: '调试'),
          SwitchListTile(
            title: const Text('模拟设备模式'),
            subtitle: const Text('无需真实硬件，使用虚拟设备进行界面演示'),
            secondary: const Icon(Icons.devices_other),
            value: session.isFakeMode,
            onChanged: session.enableFakeMode,
          ),
          const Divider(),
          const _SectionHeader(title: '关于'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('欧思魔控'),
            subtitle: const Text('Osmo 设备 Flutter 控制端 v1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('开源许可'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
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
