import 'dart:async';

import 'package:flutter/material.dart';

enum ToastType { success, error, info }

void showTopToast(
  BuildContext context, {
  required String message,
  ToastType type = ToastType.info,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _TopToast(
      message: message,
      type: type,
      duration: duration,
      onDismissed: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _TopToast extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopToast({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
    _timer = Timer(widget.duration, () {
      if (!mounted) return;
      setState(() => _visible = false);
      Future.delayed(const Duration(milliseconds: 250), widget.onDismissed);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = switch (widget.type) {
      ToastType.success => scheme.primaryContainer,
      ToastType.error => scheme.errorContainer,
      ToastType.info => scheme.surface,
    };
    final foreground = switch (widget.type) {
      ToastType.success => scheme.onPrimaryContainer,
      ToastType.error => scheme.onErrorContainer,
      ToastType.info => scheme.onSurface,
    };
    final icon = switch (widget.type) {
      ToastType.success => Icons.check_circle,
      ToastType.error => Icons.error,
      ToastType.info => Icons.info,
    };

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0, -0.2),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: scheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: foreground, size: 20),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: foreground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
