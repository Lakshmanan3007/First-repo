import 'package:flutter/material.dart';

import '../../../core/theme/trace_spacing.dart';
import '../../../core/theme/trace_typography.dart';

/// Confirmation + optional message before completing or failing a task.
Future<String?> showTaskOutcomeDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String defaultNote,
}) async {
  final controller = TextEditingController(text: defaultNote);

  final result = await showDialog<String?>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: TraceTypography.headlineSm),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message, style: TraceTypography.bodyMd),
          const SizedBox(height: TraceSpacing.md),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Optional message',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  controller.dispose();
  return result;
}
