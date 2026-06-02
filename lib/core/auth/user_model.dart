import 'package:flutter/foundation.dart';

enum UserRole { student, admin }

enum LoginProvider { google, kakao, naver }

@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.school,
    required this.dormitory,
    required this.loginProvider,
    this.isSchoolVerified = false,
    this.discountCoupons = 0,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String school;
  final String dormitory;
  final LoginProvider loginProvider;
  final bool isSchoolVerified;
  final int discountCoupons;

  bool get isAdmin => role == UserRole.admin;

  AppUser copyWith({bool? isSchoolVerified, int? discountCoupons}) {
    return AppUser(
      id: id,
      name: name,
      email: email,
      role: role,
      school: school,
      dormitory: dormitory,
      loginProvider: loginProvider,
      isSchoolVerified: isSchoolVerified ?? this.isSchoolVerified,
      discountCoupons: discountCoupons ?? this.discountCoupons,
    );
  }
}
