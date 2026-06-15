import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/liquid_glass.dart';
import '../../../shared/widgets/toss.dart';
import '../domain/reservation_provider.dart';

class ReservationScreen extends ConsumerStatefulWidget {
  const ReservationScreen({super.key});

  @override
  ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends ConsumerState<ReservationScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _showCancelDialog(Reservation reservation) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showGlassDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.bgSurfaceDark : Colors.white,
        title: Text('예약 취소',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87)),
        content: Text(
          '${reservation.facilityName} 예약을 취소하시겠습니까?\n${reservation.date} ${reservation.timeSlot}',
          style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('닫기',
                  style: TextStyle(fontWeight: FontWeight.w600))),
          TextButton(
            onPressed: () {
              ref.read(reservationProvider.notifier).cancel(reservation.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('예약이 성공적으로 취소되었습니다.'),
                    behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('취소하기',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reservations = ref.watch(reservationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: primaryTextColor),
            onPressed: () => context.pop(),
          ),
          title: Text('나의 예약 내역',
              style: TextStyle(
                  color: primaryTextColor, fontWeight: FontWeight.w900)),
        ),
        body: _isLoading
            ? const _SkeletonLoader()
            : reservations.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: reservations.length,
                    itemBuilder: (context, index) => Appear(
                      index: index,
                      child: _ReservationCard(
                        reservation: reservations[index],
                        onCancel: () => _showCancelDialog(reservations[index]),
                      ),
                    ),
                  ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation, required this.onCancel});
  final Reservation reservation;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final (statusColor, statusBg) = switch (reservation.status) {
      ReservationStatus.confirmed => (
          AppColors.available,
          isDark
              ? AppColors.available.withValues(alpha: 0.15)
              : AppColors.primaryBg
        ),
      ReservationStatus.pending => (
          AppColors.warning,
          isDark
              ? AppColors.warning.withValues(alpha: 0.15)
              : const Color(0xFFFFF8E8)
        ),
      ReservationStatus.cancelled => (
          AppColors.textMuted,
          isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.bgElevated
        ),
    };

    final isCancellable = reservation.status != ReservationStatus.cancelled;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCancellable
                        ? (isDark
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.primaryBg)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.bgElevated)),
                child: Icon(_facilityIcon(reservation.facilityName),
                    size: 20,
                    color: isCancellable
                        ? AppColors.primary
                        : AppColors.textMuted),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.facilityName,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isCancellable
                              ? primaryTextColor
                              : AppColors.textMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reservation.date,
                      style: TextStyle(
                          fontSize: 12,
                          color: isCancellable
                              ? secondaryTextColor
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3), width: 1.0),
                ),
                child: Text(reservation.status.label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _InfoItem(
                  icon: Icons.access_time_rounded,
                  label: reservation.timeSlot,
                  isCancellable: isCancellable),
              const SizedBox(width: 20),
              _InfoItem(
                  icon: Icons.people_rounded,
                  label: '${reservation.peopleCount}명',
                  isCancellable: isCancellable),
              const Spacer(),
              if (isCancellable)
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.2),
                          width: 1.0),
                    ),
                    child: const Text('취소하기',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.error)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _facilityIcon(String name) {
    if (name.contains('세탁')) return Icons.local_laundry_service_rounded;
    if (name.contains('체육') || name.contains('헬스')) {
      return Icons.fitness_center_rounded;
    }
    if (name.contains('식당')) return Icons.restaurant_rounded;
    return Icons.apartment_rounded;
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem(
      {required this.icon, required this.label, required this.isCancellable});
  final IconData icon;
  final String label;
  final bool isCancellable;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isCancellable
        ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
        : AppColors.textMuted;
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 13, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SkeletonLoader extends StatefulWidget {
  const _SkeletonLoader();

  @override
  State<_SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<_SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _opacity = Tween(begin: 0.05, end: 0.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, _) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 120,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: _opacity.value),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_busy_rounded,
                size: 64,
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          Text('아직 예약된 내역이 없어요',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Text('시설 안내 탭에서 간편하게 예약해보세요',
              style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
