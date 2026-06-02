import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../domain/facility_provider.dart';
import '../../meal_rating/presentation/meal_rating_dialog.dart';
import '../../../core/payment/payment_provider.dart';

class FacilityScreen extends ConsumerWidget {
  const FacilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _LaundrySection(),
          const SizedBox(height: 20),
          _GymSection(),
          const SizedBox(height: 20),
          _CafeteriaSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 세탁실
// ─────────────────────────────────────────────────────────
class _LaundrySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machines = ref.watch(laundryProvider);
    final available = machines.where((m) => m.status == MachineStatus.available).length;

    return _Card(
      title: '세탁실',
      icon: Icons.local_laundry_service,
      trailing: Text(
        '$available대 사용가능',
        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
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
    final (color, label) = switch (machine.status) {
      MachineStatus.available => (Colors.white, '사용가능'),
      MachineStatus.running => (Colors.white.withValues(alpha: 0.7), machine.remainingMinutes != null ? '${machine.remainingMinutes}분 남음' : '사용중'),
      MachineStatus.outOfOrder => (Colors.white.withValues(alpha: 0.3), '점검중'),
    };

    return GlassContainer(
      padding: EdgeInsets.zero,
      opacity: 0.05,
      borderOpacity: 0.1,
      borderRadius: 12,
      blurSigma: 8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_laundry_service, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            '${machine.id}번',
            style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4)),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 체육관
// ─────────────────────────────────────────────────────────
class _GymSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gym = ref.watch(gymProvider);

    final statusColor = switch (gym.label) {
      '여유' => Colors.white,
      '보통' => Colors.white.withValues(alpha: 0.8),
      _ => Colors.white.withValues(alpha: 0.6),
    };

    return _Card(
      title: '체육관',
      icon: Icons.fitness_center,
      trailing: Text(
        gym.label,
        style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '현재 ${gym.occupancy}명 / 최대 ${gym.capacity}명',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: gym.ratio,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(color: Colors.white.withValues(alpha: 0.2), blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '운영시간: 06:00 ~ 23:00',
            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 식당
// ─────────────────────────────────────────────────────────
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
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      opacity: 0.05,
      borderOpacity: 0.1,
      borderRadius: 12,
      blurSigma: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                menu.mealType,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              Text(
                '${menu.price}원',
                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            menu.items.join(' · '),
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final method = ref.read(paymentMethodProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('단말기에 휴대폰을 태그해주세요. ($method)'),
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.nfc, size: 18),
              label: Text(
                '${menu.price}원 자동 결제'.toUpperCase(),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// ─────────────────────────────────────────────────────────
// 공통 카드 위젯
// ─────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.title, required this.icon, required this.child, this.trailing});
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
