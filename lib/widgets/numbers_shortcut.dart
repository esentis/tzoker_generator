import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tzoker_generator/widgets/numbers_dialog.dart';

class NumberStatsDialog extends Intent {
  const NumberStatsDialog();
}

class NumbersShortcut extends StatefulWidget {
  const NumbersShortcut({required this.child, super.key});
  final Widget child;
  @override
  State<NumbersShortcut> createState() => _NumbersShortcutState();
}

class _NumbersShortcutState extends State<NumbersShortcut> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.keyK):
              const NumberStatsDialog(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            NumberStatsDialog: CallbackAction<NumberStatsDialog>(
              onInvoke: (NumberStatsDialog intent) {
                return Get.dialog(
                  const Center(child: NumbersDialog()),
                );
              },
            ),
          },
          child: Focus(
            autofocus: true,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
