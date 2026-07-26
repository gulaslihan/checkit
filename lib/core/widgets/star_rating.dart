import 'package:flutter/material.dart';

/// 5-star rating row. Tapping the currently-set star clears the rating.
class StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  final double size;

  const StarRating({super.key, required this.rating, required this.onChanged, this.size = 20});

  static const _starColor = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final filled = starValue <= rating;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(starValue == rating ? 0 : starValue),
          child: Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              size: size,
              color: _starColor,
            ),
          ),
        );
      }),
    );
  }
}
