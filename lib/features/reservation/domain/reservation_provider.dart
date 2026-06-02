import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReservationStatus { confirmed, pending, cancelled }

extension ReservationStatusX on ReservationStatus {
  String get label => switch (this) {
    ReservationStatus.confirmed => '확정',
    ReservationStatus.pending   => '대기중',
    ReservationStatus.cancelled => '취소됨',
  };
}

@immutable
class Reservation {
  const Reservation({
    required this.id,
    required this.facilityName,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.peopleCount,
  });
  final String id;
  final String facilityName;
  final String date;
  final String timeSlot;
  final ReservationStatus status;
  final int peopleCount;

  Reservation copyWith({ReservationStatus? status}) => Reservation(
    id: id, facilityName: facilityName, date: date, timeSlot: timeSlot,
    status: status ?? this.status, peopleCount: peopleCount,
  );
}

// 예약 더미 데이터 생성기 (상용 서비스 느낌)
List<Reservation> _generateReservations() {
  const curated = [
    Reservation(id: 'r1', facilityName: '체육관',     date: '2026.06.05', timeSlot: '18:00 ~ 19:00', status: ReservationStatus.confirmed, peopleCount: 4),
    Reservation(id: 'r2', facilityName: '세탁실 2번', date: '2026.06.04', timeSlot: '14:00 ~ 14:30', status: ReservationStatus.pending,   peopleCount: 1),
    Reservation(id: 'r3', facilityName: '체육관',     date: '2026.06.03', timeSlot: '20:00 ~ 21:00', status: ReservationStatus.confirmed, peopleCount: 2),
    Reservation(id: 'r4', facilityName: '세탁실 1번', date: '2026.06.02', timeSlot: '10:00 ~ 10:30', status: ReservationStatus.confirmed, peopleCount: 1),
    Reservation(id: 'r5', facilityName: '체육관',     date: '2026.06.01', timeSlot: '07:00 ~ 08:00', status: ReservationStatus.confirmed, peopleCount: 3),
    Reservation(id: 'r6', facilityName: '세탁실 4번', date: '2026.05.30', timeSlot: '16:00 ~ 16:30', status: ReservationStatus.confirmed, peopleCount: 1),
    Reservation(id: 'r7', facilityName: '세탁실 5번', date: '2026.05.28', timeSlot: '09:00 ~ 09:30', status: ReservationStatus.cancelled, peopleCount: 1),
    Reservation(id: 'r8', facilityName: '체육관',     date: '2026.05.25', timeSlot: '19:00 ~ 20:00', status: ReservationStatus.cancelled, peopleCount: 5),
  ];

  const facilities = ['체육관', '세탁실 1번', '세탁실 2번', '세탁실 3번', '세탁실 4번', '세탁실 6번', '스터디룸 A', '스터디룸 B', '세미나실'];
  const slots = ['07:00 ~ 08:00', '09:00 ~ 10:00', '11:00 ~ 12:00', '13:00 ~ 14:00', '15:00 ~ 16:00', '18:00 ~ 19:00', '20:00 ~ 21:00', '21:00 ~ 22:00'];
  const statuses = [ReservationStatus.confirmed, ReservationStatus.confirmed, ReservationStatus.pending, ReservationStatus.cancelled];

  final generated = <Reservation>[];
  for (var i = 0; i < 34; i++) {
    final seed = (i + 1) * 41;
    final day = (seed % 27) + 1;
    final month = 4 + (seed % 3); // 4~6월
    generated.add(Reservation(
      id: 'rg$i',
      facilityName: facilities[seed % facilities.length],
      date: '2026.${month.toString().padLeft(2, '0')}.${day.toString().padLeft(2, '0')}',
      timeSlot: slots[seed % slots.length],
      status: statuses[seed % statuses.length],
      peopleCount: (seed % 5) + 1,
    ));
  }

  // 날짜 내림차순 정렬
  final all = [...curated, ...generated];
  all.sort((a, b) => b.date.compareTo(a.date));
  return all;
}

class ReservationNotifier extends StateNotifier<List<Reservation>> {
  ReservationNotifier() : super(_generateReservations());

  void cancel(String id) {
    state = state.map((r) => r.id == id ? r.copyWith(status: ReservationStatus.cancelled) : r).toList();
  }
}

final reservationProvider = StateNotifierProvider<ReservationNotifier, List<Reservation>>(
  (ref) => ReservationNotifier(),
);
