import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Decorative campus garden. No student, institution, or clinical data is shown.
class ThriveGrowthIllustration extends StatelessWidget {
  const ThriveGrowthIllustration({super.key});

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: CustomPaint(painter: _CampusGardenPainter()),
  );
}

class _CampusGardenPainter extends CustomPainter {
  const _CampusGardenPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE4F2EE), Color(0xFFF2F6E9)],
        ).createShader(bounds),
    );
    final scale = math.min(size.width / 400, size.height / 220);
    canvas.save();
    canvas.translate((size.width - 400 * scale) / 2, size.height - 220 * scale);
    canvas.scale(scale);

    _circle(canvas, const Offset(325, 43), 26, const Color(0xFFF4D58F));
    _cloud(canvas, const Offset(86, 42), 1);
    _cloud(canvas, const Offset(284, 73), .6);
    final farHill = Path()
      ..moveTo(0, 136)
      ..cubicTo(60, 80, 106, 114, 164, 126)
      ..cubicTo(240, 66, 334, 90, 400, 127)
      ..lineTo(400, 220)
      ..lineTo(0, 220)
      ..close();
    canvas.drawPath(farHill, Paint()..color = const Color(0xFFC9DED0));
    final nearHill = Path()
      ..moveTo(0, 166)
      ..cubicTo(99, 122, 249, 171, 400, 138)
      ..lineTo(400, 220)
      ..lineTo(0, 220)
      ..close();
    canvas.drawPath(nearHill, Paint()..color = const Color(0xFFA9CAB3));

    _building(canvas, const Rect.fromLTWH(74, 110, 72, 60));
    _building(canvas, const Rect.fromLTWH(255, 113, 82, 54));
    _tree(canvas, const Offset(42, 181), 102, const Color(0xFF407F6C));
    _tree(canvas, const Offset(73, 169), 62, const Color(0xFF73A17D));
    _tree(canvas, const Offset(357, 177), 104, const Color(0xFF4D8F77));
    _tree(canvas, const Offset(331, 173), 65, const Color(0xFF7FA782));

    final lawn = Path()
      ..moveTo(0, 185)
      ..cubicTo(92, 155, 316, 155, 400, 185)
      ..lineTo(400, 220)
      ..lineTo(0, 220)
      ..close();
    canvas.drawPath(lawn, Paint()..color = const Color(0xFFDBE8CC));
    final walkway = Path()
      ..moveTo(176, 153)
      ..lineTo(219, 153)
      ..cubicTo(212, 179, 225, 187, 273, 220)
      ..lineTo(119, 220)
      ..cubicTo(171, 189, 187, 176, 176, 153)
      ..close();
    canvas.drawPath(walkway, Paint()..color = const Color(0xFFF3EAD5));
    final walkwayEdge = Path()
      ..moveTo(220, 163)
      ..cubicTo(213, 185, 245, 208, 266, 220);
    canvas.drawPath(
      walkwayEdge,
      Paint()
        ..color = const Color(0xFFE4D4B5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    _arch(canvas);
    _tree(canvas, const Offset(118, 184), 87, const Color(0xFF225E57));
    _tree(canvas, const Offset(285, 184), 84, const Color(0xFF306F60));
    _shrub(canvas, const Offset(17, 196), 28);
    _shrub(canvas, const Offset(90, 198), 24);
    _shrub(canvas, const Offset(312, 196), 26);
    _shrub(canvas, const Offset(385, 200), 35);

    final pole = Paint()
      ..color = const Color(0xFF466F65)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(276, 111), const Offset(276, 53), pole);
    final flag = Path()
      ..moveTo(277, 53)
      ..quadraticBezierTo(286, 57, 300, 53)
      ..lineTo(300, 68)
      ..quadraticBezierTo(286, 72, 277, 68)
      ..close();
    canvas.drawPath(flag, Paint()..color = const Color(0xFF168C80));
    for (final point in [
      const Offset(68, 199),
      const Offset(110, 211),
      const Offset(302, 206),
      const Offset(352, 207),
    ]) {
      _circle(canvas, point, 3, const Color(0xFFE3A78C));
      _circle(canvas, point.translate(4, -3), 2, const Color(0xFFF4D58F));
    }
    canvas.restore();
  }

  void _arch(Canvas canvas) {
    final arch = Path()
      ..moveTo(146, 179)
      ..lineTo(146, 106)
      ..cubicTo(146, 42, 254, 42, 254, 106)
      ..lineTo(254, 179)
      ..lineTo(230, 179)
      ..lineTo(230, 108)
      ..cubicTo(230, 73, 170, 73, 170, 108)
      ..lineTo(170, 179)
      ..close();
    canvas.drawPath(
      arch.shift(const Offset(4, 0)),
      Paint()..color = const Color(0xFFB8A385),
    );
    canvas.drawPath(arch, Paint()..color = const Color(0xFFE4CEAC));
    final joints = Paint()
      ..color = const Color(0xFFC8B28F)
      ..strokeWidth = 1;
    for (final y in [112.0, 132.0, 152.0, 172.0]) {
      canvas.drawLine(Offset(146, y), Offset(170, y), joints);
      canvas.drawLine(Offset(230, y), Offset(254, y), joints);
    }
    canvas.drawLine(const Offset(200, 58), const Offset(200, 81), joints);
    canvas.drawLine(const Offset(174, 64), const Offset(183, 85), joints);
    canvas.drawLine(const Offset(226, 64), const Offset(217, 85), joints);
    canvas.drawLine(const Offset(155, 81), const Offset(174, 96), joints);
    canvas.drawLine(const Offset(245, 81), const Offset(226, 96), joints);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(140, 174, 36, 7),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFC2AD8C),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(224, 174, 36, 7),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFC2AD8C),
    );
  }

  void _building(Canvas canvas, Rect rect) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()..color = const Color(0xFFE9DFCB),
    );
    canvas.drawRect(
      Rect.fromLTWH(rect.left - 3, rect.top, rect.width + 6, 5),
      Paint()..color = const Color(0xFFD2C3A8),
    );
    for (var x = rect.left + 12; x < rect.right - 6; x += 17) {
      for (var y = rect.top + 14; y < rect.bottom - 8; y += 18) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 7, 10),
            const Radius.circular(3),
          ),
          Paint()..color = const Color(0xFF87A99A),
        );
      }
    }
  }

  void _tree(Canvas canvas, Offset base, double height, Color color) {
    final trunk = Paint()
      ..color = const Color(0xFF6F8771)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, base.translate(0, -height * .8), trunk);
    final crown = Path()
      ..moveTo(base.dx, base.dy - height)
      ..cubicTo(
        base.dx - height * .1,
        base.dy - height * .75,
        base.dx - height * .28,
        base.dy - height * .3,
        base.dx - height * .22,
        base.dy - height * .18,
      )
      ..quadraticBezierTo(
        base.dx,
        base.dy - height * .08,
        base.dx + height * .22,
        base.dy - height * .18,
      )
      ..cubicTo(
        base.dx + height * .28,
        base.dy - height * .3,
        base.dx + height * .1,
        base.dy - height * .75,
        base.dx,
        base.dy - height,
      )
      ..close();
    canvas.drawPath(crown, Paint()..color = color);
    canvas.drawLine(
      base.translate(0, -height * .15),
      base.translate(0, -height * .7),
      Paint()
        ..color = Colors.white.withValues(alpha: .15)
        ..strokeWidth = 1,
    );
  }

  void _shrub(Canvas canvas, Offset base, double width) {
    const color = Color(0xFF79A080);
    _circle(
      canvas,
      base.translate(-width * .23, -width * .17),
      width * .28,
      color,
    );
    _circle(
      canvas,
      base.translate(width * .17, -width * .3),
      width * .36,
      color,
    );
    _circle(
      canvas,
      base.translate(width * .42, -width * .1),
      width * .25,
      color,
    );
  }

  void _cloud(Canvas canvas, Offset center, double scale) {
    final color = Colors.white.withValues(alpha: .7);
    _circle(canvas, center, 12 * scale, color);
    _circle(canvas, center.translate(15 * scale, 4 * scale), 9 * scale, color);
    _circle(canvas, center.translate(-12 * scale, 5 * scale), 7 * scale, color);
  }

  void _circle(Canvas canvas, Offset center, double radius, Color color) =>
      canvas.drawCircle(center, radius, Paint()..color = color);

  @override
  bool shouldRepaint(_CampusGardenPainter oldDelegate) => false;
}
