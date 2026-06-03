import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../domain/facility_provider.dart';

class FacilityScreen extends ConsumerWidget {
  const FacilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primaryBg),
                    child: const Icon(Icons.event_note_outlined, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('예약 내역', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text('나의 시설 예약 현황 확인', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
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

// ── 세탁실 (세탁기 + 건조기) ───────────────────────────────────────────

class _LaundrySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final washers = ref.watch(washingMachinesProvider);
    final dryers = ref.watch(dryersProvider);
    final washAvail = washers.where((m) => m.status == MachineStatus.available).length;
    final dryAvail = dryers.where((m) => m.status == MachineStatus.available).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _Card(
      title: '세탁실',
      icon: Icons.local_laundry_service,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primaryBg, borderRadius: BorderRadius.circular(500)),
        child: Text('세탁 $washAvail · 건조 $dryAvail 가능',
            style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MachineGroup(label: '세탁기', icon: Icons.local_laundry_service, machines: washers),
          const SizedBox(height: 16),
          _MachineGroup(label: '건조기', icon: Icons.dry_cleaning, machines: dryers),
        ],
      ),
    );
  }
}

class _MachineGroup extends StatelessWidget {
  const _MachineGroup({required this.label, required this.icon, required this.machines});
  final String label;
  final IconData icon;
  final List<LaundryMachine> machines;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
          children: machines.map((m) => _MachineChip(machine: m, icon: icon)).toList(),
        ),
      ],
    );
  }
}

class _MachineChip extends StatelessWidget {
  const _MachineChip({required this.machine, required this.icon});
  final LaundryMachine machine;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (color, bgColor, label) = switch (machine.status) {
      MachineStatus.available  => (AppColors.available, isDark ? AppColors.available.withValues(alpha: 0.1) : AppColors.primaryBg, '사용가능'),
      MachineStatus.running    => (AppColors.running, isDark ? AppColors.running.withValues(alpha: 0.1) : const Color(0xFFEFF5FF), machine.remainingMinutes != null ? '${machine.remainingMinutes}분' : '사용중'),
      MachineStatus.outOfOrder => (AppColors.outOfOrder, isDark ? AppColors.outOfOrder.withValues(alpha: 0.1) : const Color(0xFFFFF0F0), '점검중'),
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
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text('${machine.id}번', style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.6))),
          Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── 헬스장 (현재 이용인원 / 최대수용인원 · 혼잡도) ──────────────────────

class _GymSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gym = ref.watch(gymProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (statusColor, statusBg) = switch (gym.label) {
      '여유'   => (AppColors.available, isDark ? AppColors.available.withValues(alpha: 0.15) : AppColors.primaryBg),
      '보통'   => (AppColors.warning,   isDark ? AppColors.warning.withValues(alpha: 0.15) : const Color(0xFFFFF8E8)),
      _        => (AppColors.outOfOrder, isDark ? AppColors.error.withValues(alpha: 0.15) : const Color(0xFFFFF0F0)),
    };

    return _Card(
      title: '헬스장',
      icon: Icons.fitness_center,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(500)),
        child: Text(gym.label, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w700)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${gym.occupancy}', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: statusColor)),
              Text(' 명', style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('최대 ${gym.capacity}명 · 이용률 ${(gym.ratio * 100).round()}%',
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: gym.ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: isDark ? AppColors.bgElevatedDark : Colors.black.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 8),
          Text('운영시간: 06:00 ~ 23:00', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── 식당 (식단 + 영양성분) ─────────────────────────────────────────────

class _CafeteriaSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menus = ref.watch(cafeteriaMenuProvider);

    return _Card(
      title: '식당',
      icon: Icons.restaurant,
      child: Column(
        children: menus.map((menu) => _MenuRow(menu: menu)).toList(),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.menu});
  final CafeteriaMenu menu;

  @override
  Widget build(BuildContext context) {
    final n = menu.nutrition;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              Row(
                children: [
                  Text(menu.mealType, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textPrimary)),
                  const SizedBox(width: 8),
                  Text('${n.kcal} kcal', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
              Text('${menu.price}원', style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Text(menu.items.join(' · '), style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
          const SizedBox(height: 14),
          // 영양성분
          Row(
            children: [
              _NutrientChip(label: '탄수화물', value: '${n.carbs}g'),
              const SizedBox(width: 8),
              _NutrientChip(label: '단백질', value: '${n.protein}g'),
              const SizedBox(width: 8),
              _NutrientChip(label: '지방', value: '${n.fat}g'),
            ],
          ),
        ],
      ),
    );
  }
}

class _NutrientChip extends StatelessWidget {
  const _NutrientChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w800)),
          ],
        ),
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
