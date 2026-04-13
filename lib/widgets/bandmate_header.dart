import 'package:flutter/material.dart';

/// Top bar: pick-style logo, app title, notifications (English UI).
class BandmateHeader extends StatelessWidget {
  const BandmateHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _PickLogo(color: theme.colorScheme.onSurface),
              const SizedBox(width: 12),
              Text(
                'BandMate',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
                tooltip: 'Notifications',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickLogo extends StatelessWidget {
  const _PickLogo({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: CustomPaint(
        painter: _GuitarPickPainter(outline: color),
        child: Center(
          child: Icon(Icons.music_note, size: 22, color: color),
        ),
      ),
    );
  }
}

class _GuitarPickPainter extends CustomPainter {
  _GuitarPickPainter({required this.outline});

  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..quadraticBezierTo(w * 0.92, h * 0.35, w * 0.88, h * 0.62)
      ..quadraticBezierTo(w * 0.82, h * 0.95, w * 0.5, h * 0.98)
      ..quadraticBezierTo(w * 0.18, h * 0.95, w * 0.12, h * 0.62)
      ..quadraticBezierTo(w * 0.08, h * 0.35, w * 0.5, h * 0.08)
      ..close();

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = outline.withValues(alpha: 0.08);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = outline;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
