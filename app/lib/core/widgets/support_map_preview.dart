import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SupportMapPreview extends StatelessWidget {
  const SupportMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: const Color(0xFFEAF3F4),
                child: CustomPaint(painter: _MapLinesPainter()),
              ),
            ),
            const _MapPin(left: 56, top: 66, label: 'Delegacia'),
            const _MapPin(left: 214, top: 52, label: 'Defensoria'),
            const _MapPin(left: 168, top: 142, label: 'Acolhimento'),
            Positioned(
              right: 12,
              top: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A1F2433), blurRadius: 8),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text('Filtros'),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1A1F2433), blurRadius: 8),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.place_outlined, color: AppColors.pink),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Serviços de apoio próximos',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.left, required this.top, required this.label});

  final double left;
  final double top;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.pink,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 3),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _MapLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC8D8DB)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(-10, size.height * .18)
      ..quadraticBezierTo(size.width * .38, size.height * .38, size.width + 10,
          size.height * .12)
      ..moveTo(size.width * .08, size.height + 10)
      ..quadraticBezierTo(size.width * .45, size.height * .56, size.width * .85, -10);
    canvas.drawPath(path, paint);

    final minor = Paint()
      ..color = const Color(0xFFD9E4E5)
      ..strokeWidth = 2;
    for (var offset = 20.0; offset < size.width; offset += 42) {
      canvas.drawLine(Offset(offset, 0), Offset(offset - 34, size.height), minor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
