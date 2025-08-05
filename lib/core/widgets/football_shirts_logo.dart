import 'package:flutter/material.dart';

class FootballShirtsLogo extends StatelessWidget {
  final double size;
  final Color? textColor;
  final Color? iconColor;

  const FootballShirtsLogo({
    super.key,
    this.size = 200,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: size * 0.6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          'assets/images/image.png',
          width: double.infinity,
          height: size * 0.6,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image is not found
            return _buildFallbackLogo();
          },
        ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveIconColor = iconColor ?? Colors.white;
    final fontSize = (size * 0.08).clamp(16.0, 20.0);

    return Container(
      width: double.infinity,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Left side - Person icon with shield
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(size * 0.08),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shield background
                  Container(
                    width: size * 0.25,
                    height: size * 0.3,
                    decoration: BoxDecoration(
                      border: Border.all(color: effectiveIconColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Person icon
                  Icon(
                    Icons.person,
                    size: size * 0.18,
                    color: effectiveIconColor,
                  ),
                ],
              ),
            ),
          ),

          // Vertical separator
          Container(
            width: 1,
            height: size * 0.35,
            color: effectiveIconColor.withOpacity(0.5),
          ),

          // Right side - Text
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(size * 0.06),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FOOTBALL',
                    style: TextStyle(
                      color: effectiveTextColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: size * 0.015),
                  Text(
                    'SHIRTS',
                    style: TextStyle(
                      color: effectiveTextColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
