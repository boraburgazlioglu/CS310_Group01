import 'package:flutter/material.dart';
import '../utils/padding.dart';
import '../utils/colors.dart';
import '../utils/text.dart';

//appbar widget with logo and notifications button
class BandmateHeader extends StatelessWidget implements PreferredSizeWidget {
  const BandmateHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: AppPadding.allL,
          child: Row(
            children: [
              _PickLogo(color: AppColors.primary),
              const SizedBox(width: AppPadding.M),
              Text(
                'BandMate',
                style: AppTexts.headL,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
                icon: const Icon(Icons.notifications_none, color: AppColors.primary),
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
