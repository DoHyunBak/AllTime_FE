import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MachineStatus { available, running, outOfOrder }

enum LaundryKind { washer, dryer }

@immutable
class LaundryMachine {
  const LaundryMachine({required this.id, required this.kind, required this.status, this.remainingMinutes});
  final int id;
  final LaundryKind kind;
  final MachineStatus status;
  final int? remainingMinutes;
}

@immutable
class GymStatus {
  const GymStatus({required this.occupancy, required this.capacity});
  final int occupancy;
  final int capacity;
  double get ratio => occupancy / capacity;
  String get label {
    if (ratio < 0.4) return '여유';
    if (ratio < 0.75) return '보통';
    return '혼잡';
  }
}

@immutable
class Nutrition {
  const Nutrition({required this.kcal, required this.carbs, required this.protein, required this.fat});
  final int kcal;      // 열량 (kcal)
  final int carbs;     // 탄수화물 (g)
  final int protein;   // 단백질 (g)
  final int fat;       // 지방 (g)
}

@immutable
class CafeteriaMenu {
  const CafeteriaMenu({required this.mealType, required this.items, required this.price, required this.nutrition});
  final String mealType;
  final List<String> items;
  final int price;
  final Nutrition nutrition;
}

final _mockMachines = [
  // 세탁기
  const LaundryMachine(id: 1, kind: LaundryKind.washer, status: MachineStatus.available),
  const LaundryMachine(id: 2, kind: LaundryKind.washer, status: MachineStatus.running, remainingMinutes: 18),
  const LaundryMachine(id: 3, kind: LaundryKind.washer, status: MachineStatus.running, remainingMinutes: 32),
  const LaundryMachine(id: 4, kind: LaundryKind.washer, status: MachineStatus.available),
  const LaundryMachine(id: 5, kind: LaundryKind.washer, status: MachineStatus.available),
  const LaundryMachine(id: 6, kind: LaundryKind.washer, status: MachineStatus.outOfOrder),
  // 건조기
  const LaundryMachine(id: 1, kind: LaundryKind.dryer, status: MachineStatus.running, remainingMinutes: 45),
  const LaundryMachine(id: 2, kind: LaundryKind.dryer, status: MachineStatus.available),
  const LaundryMachine(id: 3, kind: LaundryKind.dryer, status: MachineStatus.running, remainingMinutes: 12),
  const LaundryMachine(id: 4, kind: LaundryKind.dryer, status: MachineStatus.available),
];

final _mockGym = const GymStatus(occupancy: 8, capacity: 30);

final _mockMenus = [
  const CafeteriaMenu(
    mealType: '아침',
    items: ['흰쌀밥', '된장국', '계란후라이', '깍두기'],
    price: 2500,
    nutrition: Nutrition(kcal: 520, carbs: 78, protein: 18, fat: 14),
  ),
  const CafeteriaMenu(
    mealType: '점심',
    items: ['흰쌀밥', '제육볶음', '미역국', '시금치나물', '김치'],
    price: 3500,
    nutrition: Nutrition(kcal: 780, carbs: 95, protein: 32, fat: 26),
  ),
  const CafeteriaMenu(
    mealType: '저녁',
    items: ['흰쌀밥', '돈까스', '유부국', '콩나물무침', '배추김치'],
    price: 3500,
    nutrition: Nutrition(kcal: 850, carbs: 102, protein: 29, fat: 34),
  ),
];

final washingMachinesProvider = Provider<List<LaundryMachine>>(
  (ref) => _mockMachines.where((m) => m.kind == LaundryKind.washer).toList(),
);
final dryersProvider = Provider<List<LaundryMachine>>(
  (ref) => _mockMachines.where((m) => m.kind == LaundryKind.dryer).toList(),
);

// 마지막 식사 결제 정보 (평가 팝업 트리거용)
class LastMealPayment {
  const LastMealPayment({required this.menuName, required this.paidAt});
  final String menuName;
  final DateTime paidAt;
}

class MealPaymentNotifier extends StateNotifier<LastMealPayment?> {
  MealPaymentNotifier() : super(null);

  void pay(String menuName) {
    state = LastMealPayment(menuName: menuName, paidAt: DateTime.now());
  }

  void clear() => state = null;
}

final laundryProvider = Provider<List<LaundryMachine>>((ref) => _mockMachines);
final gymProvider = Provider<GymStatus>((ref) => _mockGym);
final cafeteriaMenuProvider = Provider<List<CafeteriaMenu>>((ref) => _mockMenus);
final mealPaymentProvider = StateNotifierProvider<MealPaymentNotifier, LastMealPayment?>((ref) {
  return MealPaymentNotifier();
});
