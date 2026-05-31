import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Context 기반 스타일 토스트 (권장).
void showToast(BuildContext context, String message, {IconData? icon}) {
  final fToast = FToast()..init(context);
  fToast.showToast(
    toastDuration: const Duration(seconds: 2),
    gravity: ToastGravity.BOTTOM,
    child: _ToastWidget(message: message, icon: icon),
  );
}

/// Context 없이 사용 가능한 기본 토스트 (fallback).
void showBasicToast({required String message}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: const Color(0xDD1C1C1E),
    textColor: Colors.white,
    fontSize: 14.0,
  );
}

class _ToastWidget extends StatelessWidget {
  const _ToastWidget({required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xF01C1C1E),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
