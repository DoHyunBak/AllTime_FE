import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_container.dart';
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('예약 취소', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          '${reservation.facilityName} 예약을 취소하시겠습니까?\n${reservation.date} ${reservation.timeSlot}',
          style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('닫기')),
          TextButton(
            onPressed: () {
              ref.read(reservationProvider.notifier).cancel(reservation.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('예약이 취소되었습니다.'), duration: Duration(seconds: 2)),
              );
            },
            child: const Text('취소하기', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reservations = ref.watch(reservationProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: const Text('예약 내역', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        ),
        body: _isLoading
            ? const _SkeletonLoader()
            : reservations.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reservations.length,
                    itemBuilder: (context, index) => _ReservationCard(
                      reservation: reservations[index],
                      onCancel: () => _showCancelDialog(reservations[index]),
                    ),
                  ),
      ),
    );
  }
}

// ── 예약 카드 ─────────────────────────────────────────────────────────

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation, required this.onCancel});
  final Reservation reservation;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusBg) = switch (reservation.status) {
      ReservationStatus.confirmed => (AppColors.available, AppColors.primaryBg),
      ReservationStatus.pending   => (AppColors.warning, const Color(0xFFFFF8E8)),
      ReservationStatus.cancelled => (AppColors.textMuted, AppColors.bgElevated),
    };

    final isCancellable = reservation.status != ReservationStatus.cancelled;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: isCancellable ? AppColors.primaryBg : AppColors.bgElevated),
                child: Icon(_facilityIcon(reservation.facilityName), size: 19, color: isCancellable ? AppColors.primary : AppColors.textMuted),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.facilityName,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isCancellable ? AppColors.textPrimary : AppColors.textMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reservation.date,
                      style: TextStyle(fontSize: 12, color: isCancellable ? AppColors.textSecondary : AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(500),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 0.5),
                ),
                child: Text(reservation.status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 13, color: isCancellable ? AppColors.textSecondary : AppColors.textMuted),
              const SizedBox(width: 4),
              Text(reservation.timeSlot, style: TextStyle(fontSize: 12, color: isCancellable ? AppColors.textSecondary : AppColors.textMuted)),
              const SizedBox(width: 16),
              Icon(Icons.people_outline, size: 13, color: isCancellable ? AppColors.textSecondary : AppColors.textMuted),
              const SizedBox(width: 4),
              Text('${reservation.peopleCount}명', style: TextStyle(fontSize: 12, color: isCancellable ? AppColors.textSecondary : AppColors.textMuted)),
              const Spacer(),
              if (isCancellable)
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(500),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 0.5),
                    ),
                    child: const Text('취소', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.error)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _facilityIcon(String name) {
    if (name.contains('세탁')) return Icons.local_laundry_service;
    if (name.contains('체육')) return Icons.fitness_center;
    if (name.contains('식당')) return Icons.restaurant;
    return Icons.apartment;
  }
}

// ── 스켈레톤 로더 ─────────────────────────────────────────────────────

class _SkeletonLoader extends StatefulWidget {
  const _SkeletonLoader();

  @override
  State<_SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<_SkeletonLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _opacity = Tween(begin: 0.06, end: 0.14).animate(
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
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, _) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: _opacity.value),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
        ),
      ),
    );
  }
}

// ── 빈 상태 ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 56, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text('예약 내역이 없습니다', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          SizedBox(height: 8),
          Text('시설 화면에서 예약을 시작해보세요', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
