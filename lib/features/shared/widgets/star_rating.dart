import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double size;
  final Color? color;

  const StarRating({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (i) {
        final starValue = i + 1;
        IconData icon;
        if (rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(icon, size: size, color: color ?? AppTheme.gold);
      }),
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final double size;

  const InteractiveStarRating({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 40,
  });

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starValue = (i + 1).toDouble();
        return GestureDetector(
          onTap: () {
            setState(() => _rating = starValue);
            widget.onRatingChanged(starValue);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              _rating >= starValue
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              size: widget.size,
              color: AppTheme.gold,
            ),
          ),
        );
      }),
    );
  }
}
