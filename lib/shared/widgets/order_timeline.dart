import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.status});

  final String status;

  int get _currentIndex {
    if (status == OrderStatuses.canceled) return -1;
    final index = OrderStatuses.timeline.indexOf(status);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatuses.canceled) {
      return const AppStatusChip(status: OrderStatuses.canceled);
    }

    return Column(
      children: [
        for (var i = 0; i < OrderStatuses.timeline.length; i++) ...[
          _Step(
            label: OrderStatuses.label(OrderStatuses.timeline[i]),
            done: i <= _currentIndex,
            last: i == OrderStatuses.timeline.length - 1,
          ),
        ],
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.done, required this.last});

  final String label;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.success : const Color(0xFFCBD5E1);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              done ? LucideIcons.circleCheck : LucideIcons.circle,
              size: 20,
              color: color,
            ),
            if (!last)
              Container(
                width: 2,
                height: 22,
                color: done ? AppColors.success : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 1, bottom: 16),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: done ? FontWeight.w700 : FontWeight.w400,
              color: done ? AppColors.primary : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({super.key, required this.status});

  final String status;

  Color get _color {
    return switch (status) {
      OrderStatuses.pending => AppColors.warning,
      OrderStatuses.confirmed => AppColors.secondary,
      OrderStatuses.shipped => AppColors.primary,
      OrderStatuses.delivered => AppColors.success,
      OrderStatuses.canceled => AppColors.error,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        OrderStatuses.label(status),
        style: TextStyle(color: _color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
