import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/star_rating.dart';

class RatingSheet extends StatefulWidget {
  final String title;
  final ValueChanged<double> onRated;

  const RatingSheet({
    super.key,
    required this.title,
    required this.onRated,
  });

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.success,
            size: 56,
          ),
          const SizedBox(height: 16),
          const Text(
            'Поездка завершена!',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          InteractiveStarRating(
            initialRating: _rating,
            onRatingChanged: (r) => setState(() => _rating = r),
            size: 48,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _rating > 0 ? () => widget.onRated(_rating) : null,
            child: const Text('Отправить оценку'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => widget.onRated(5),
            child: const Text('Пропустить'),
          ),
        ],
      ),
    );
  }
}
