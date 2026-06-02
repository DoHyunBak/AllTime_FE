import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../domain/facility_provider.dart';
import '../../../core/payment/payment_provider.dart';

class FacilityScreen extends ConsumerWidget {
  const FacilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 예약 내역 바로가기 ────────────────────────────────
          GestureDetector(
            onTap: () => context.push('/reservation'),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBg),
                    child: const Icon(Icons.event_note_outlined, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('예약 내역', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        SizedBox(height: 2),
                        Text('나의 시설 예약 현황 확인', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LaundrySection(),
          const SizedBox(height: 14),
          _GymSection(),
          const SizedBox(height: 14),
          _CafeteriaSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── 세탁실 ────────────────────────────────────────────────────────────

class _LaundrySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machines = ref.watch(laundryProvider);
    final available = machines.where((m) => m.status == MachineStatus.available).length;

    return _Card(
      title: '세탁실',
      icon: Icons.local_laundry_service,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: BorderRadius.circular(500),
        ),
        child: Text('$available대 가능', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
      ),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
        children: machines.map((m) => _MachineChip(machine: m)).toList(),
      ),
    );
  }
}

class _MachineChip extends StatelessWidget {
  const _MachineChip({required this.machine});
  final LaundryMachine machine;

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, label) = switch (machine.status) {
      MachineStatus.available  => (AppColors.available, AppColors.primaryBg, '사용가능'),
      MachineStatus.running    => (AppColors.running, const Color(0xFFEFF5FF), machine.remainingMinutes != null ? '${machine.remainingMinutes}분 남음' : '사용중'),
      MachineStatus.outOfOrder => (AppColors.outOfOrder, const Color(0xFFFFF0F0), '점검중'),
    };

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_laundry_service, size: 18, color: color),
          const SizedBox(height: 5),
          Text('${machine.id}번', style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.6))),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── 체육관 ────────────────────────────────────────────────────────────

class _GymSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gym = ref.watch(gymProvider);

    final (statusColor, statusBg) = switch (gym.label) {
      '여유'   => (AppColors.available, AppColors.primaryBg),
      '보통'   => (AppColors.warning,   const Color(0xFFFFF8E8)),
      _        => (AppColors.outOfOrder, const Color(0xFFFFF0F0)),
    };

    return _Card(
      title: '체육관',
      icon: Icons.fitness_center,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(500)),
        child: Text(gym.label, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w700)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('현재 ${gym.occupancy}명 / 최대 ${gym.capacity}명', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: gym.ratio,
              minHeight: 8,
              backgroundColor: AppColors.bgElevated,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 8),
          const Text('운영시간: 06:00 ~ 23:00', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ── 식당 ──────────────────────────────────────────────────────────────

class _CafeteriaSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menus = ref.watch(cafeteriaMenuProvider);

    return _Card(
      title: '식당',
      icon: Icons.restaurant,
      child: Column(
        children: menus.map((menu) => _MenuRow(menu: menu, ref: ref)).toList(),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.menu, required this.ref});
  final CafeteriaMenu menu;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(menu.mealType, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('${menu.price}원', style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Text(menu.items.join(' · '), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final method = ref.read(paymentMethodProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('단말기에 휴대폰을 태그해주세요. ($method)'), duration: const Duration(seconds: 2)),
                );
              },
              icon: const Icon(Icons.nfc, size: 16),
              label: Text('${menu.price}원 자동 결제'.toUpperCase()),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 공통 카드 ─────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.icon, required this.child, this.trailing});
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
