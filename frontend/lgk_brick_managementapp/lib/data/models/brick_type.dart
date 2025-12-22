import 'package:json_annotation/json_annotation.dart';

part 'brick_type.g.dart';

@JsonSerializable()
class BrickType {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'current_price')
  final String? currentPrice;
  final String? unit;
  final String? category;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  BrickType({
    required this.id,
    required this.name,
    this.description,
    this.currentPrice,
    this.unit,
    this.category,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory BrickType.fromJson(Map<String, dynamic> json) =>
      _$BrickTypeFromJson(json);
  Map<String, dynamic> toJson() => _$BrickTypeToJson(this);

  // Helper methods
  bool get isActive => status == 'active';
  
  double get priceAsDouble => double.tryParse(currentPrice ?? '0') ?? 0.0;
  
  String get displayPrice => currentPrice ?? 'Not set';
  String get displayUnit => unit ?? 'Not specified';
}
