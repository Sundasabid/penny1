import 'package:equatable/equatable.dart';

class VaultEntity extends Equatable {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final String colorHex;
  final String iconName;
  final DateTime createdAt;

  const VaultEntity({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.colorHex,
    required this.iconName,
    required this.createdAt,
  });

  VaultEntity copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    String? colorHex,
    String? iconName,
    DateTime? createdAt,
  }) {
    return VaultEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        targetAmount,
        savedAmount,
        colorHex,
        iconName,
        createdAt,
      ];
}
