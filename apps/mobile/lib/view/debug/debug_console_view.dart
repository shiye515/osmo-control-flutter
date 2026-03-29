import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/debug_log_model.dart';
import '../../providers/debug_provider.dart';
import '../../utils/format_utils.dart';

class DebugConsoleView extends StatefulWidget {
  const DebugConsoleView({super.key});

  @override
  State<DebugConsoleView> createState() => _DebugConsoleViewState();
}

class _DebugConsoleViewState extends State<DebugConsoleView> {
  final TextEditingController _hexController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<Map<String, String>> _presets = [
    {'label': '版本查询', 'hex': '5512002b000204220000012100000d11'},
    {'label': '开始录制', 'hex': '551200240002042200004b01000d23'},
    {'label': '停止录制', 'hex': '551200240002042200004b00000d22'},
    {'label': '切换拍照', 'hex': '5511002300020422000034010011'},
    {'label': '休眠', 'hex': '5510002200020422000001a000011'},
  ];

  @override
  void dispose() {
    _hexController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debug = context.watch<DebugProvider>();
    final logs = debug.logs;

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('调试台'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '清除日志',
            onPressed: debug.clearLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          // Log list
          Expanded(
            child: logs.isEmpty
                ? const Center(
                    child: Text('暂无日志', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: logs.length,
                    itemBuilder: (context, i) => _LogTile(entry: logs[i]),
                  ),
          ),

          const Divider(height: 1),

          // Preset commands
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => ActionChip(
                label: Text(_presets[i]['label']!),
                onPressed: () {
                  _hexController.text = _presets[i]['hex']!;
                },
              ),
            ),
          ),

          // Hex input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hexController,
                    decoration: const InputDecoration(
                      hintText: '输入十六进制指令 (如: 55 12 00 ...)',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 12),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9a-fA-F\s]')),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    if (_hexController.text.trim().isNotEmpty) {
                      debug.sendRawHex(_hexController.text);
                    }
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(60, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final DebugLogEntry entry;
  const _LogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (entry.direction) {
      case LogDirection.sent:
        color = Colors.blue.shade700;
        icon = Icons.arrow_upward;
        break;
      case LogDirection.received:
        color = Colors.green.shade700;
        icon = Icons.arrow_downward;
        break;
      case LogDirection.system:
        color = Colors.orange.shade700;
        icon = Icons.info_outline;
        break;
    }

    return InkWell(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: entry.message));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已复制到剪贴板')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Text(
              FormatUtils.formatTime(entry.timestamp),
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontFamily: 'monospace'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.message,
                style: TextStyle(
                    fontSize: 12, color: color, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
