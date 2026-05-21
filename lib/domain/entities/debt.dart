import 'package:equatable/equatable.dart';

enum DebtType { lended, borrowed }

class DebtEntity extends Equatable {
  final String id;
  final String personName;
  final String? phoneNumber;
  final double amount;
  final DateTime dateTime;
  final DebtType type;
  final bool isSettled;

  const DebtEntity({
    required this.id,
    required this.personName,
    this.phoneNumber,
    required this.amount,
    required this.dateTime,
    required this.type,
    this.isSettled = false,
  });

  DebtEntity copyWith({
    String? id,
    String? personName,
    String? phoneNumber,
    double? amount,
    DateTime? dateTime,
    DebtType? type,
    bool? isSettled,
  }) {
    return DebtEntity(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      isSettled: isSettled ?? this.isSettled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        personName,
        phoneNumber,
        amount,
        dateTime,
        type,
        isSettled,
      ];
}
