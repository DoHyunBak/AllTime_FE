import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MachineStatus { available, running, outOfOrder }

@immutable
class LaundryMachine {
  const LaundryMachine({required this.id, required this.status, this.remainingMinutes});
  final int id;
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
class CafeteriaMenu {
  const CafeteriaMenu({required this.mealType, required this.items, required this.price});
  final String mealType;
  final List<String> items;
  final int price;
}

final _mockMachines = [
  const LaundryMachine(id: 1, status: MachineStatus.available),
  const LaundryMachine(id: 2, status: MachineStatus.running, remainingMinutes: 18),
  const LaundryMachine(id: 3, status: MachineStatus.running, remainingMinutes: 32),
  const LaundryMachine(id: 4, status: MachineStatus.available),
  const LaundryMachine(id: 5, status: MachineStatus.available),
  const LaundryMachine(id: 6, status: MachineStatus.outOfOrder),
];

final _mockGym = const GymStatus(occupancy: 8, capacity: 30);

final _mockMenus = [
  const CafeteriaMenu(
    mealType: '아침',
    items: ['흰쌀밥', '된장국', '계란후라이', '깍두기'],
    price: 2500,
  ),
  const CafeteriaMenu(
    mealType: '점심',
    items: ['흰쌀밥', '제육볶음', '미역국', '시금치나물', '김치'],
    price: 3500,
  ),
  const CafeteriaMenu(
    mealType: '저녁',
    items: ['흰쌀밥', '돈까스', '유부국', '콩나물무침', '배추김치'],
    price: 3500,
  ),
];

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
