import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final double? monthlyIncome;
  final String? currency;
  final int onyxPoints;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    this.monthlyIncome,
    this.currency,
    this.onyxPoints = 0,
  });

  static const empty = UserEntity(id: '', email: '', onyxPoints: 0);

  bool get isEmpty => this == UserEntity.empty;
  bool get isNotEmpty => this != UserEntity.empty;

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    double? monthlyIncome,
    String? currency,
    int? onyxPoints,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      currency: currency ?? this.currency,
      onyxPoints: onyxPoints ?? this.onyxPoints,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    phoneNumber,
    photoUrl,
    monthlyIncome,
    currency,
    onyxPoints,
  ];
}


