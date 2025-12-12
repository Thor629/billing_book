import 'package:flutter/material.dart';

/// A reusable dialog scaffold for create/edit screens
/// Provides consistent rounded corners, header, and save button
class DialogScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback? onSave;
  final VoidCallback? onSettings;
  final bool isSaving;
  final String saveButtonText;
  final double? width;
  final double? height;

  const DialogScaffold({
    super.key,
    required this.title,
    required this.body,
    this.onSave,
    this.onSettings,
    this.isSaving = false,
    this.saveButtonText = 'Save',
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: width ?? MediaQuery.of(context).size.width * 0.9,
        height: height ?? MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800), // Orange background
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (onSettings != null)
                    IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white),
                      onPressed: onSettings,
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isSaving ? null : onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Black button
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(saveButtonText),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: body,
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show a dialog screen
Future<T?> showDialogScreen<T>({
  required BuildContext context,
  required Widget screen,
  bool barrierDismissible = false,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => screen,
  );
}
