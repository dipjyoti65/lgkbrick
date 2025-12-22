import 'package:json_annotation/json_annotation.dart';

part 'brick_type_request.g.dart';

@JsonSerializable()
class BrickTypeRequest {
  final String name;
  final String? description;
  @JsonKey(name: 'current_price')
  final String? currentPrice;
  final String? unit;
  final String? category;
  final String? status;

  BrickTypeRequest({
    required this.name,
    this.description,
    this.currentPrice,
    this.unit,
    this.category,
    this.status,
  });

  factory BrickTypeRequest.fromJson(Map<String, dynamic> json) =>
      _$BrickTypeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BrickTypeRequestToJson(this);
}
