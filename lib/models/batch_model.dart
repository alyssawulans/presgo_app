import 'package:json_annotation/json_annotation.dart';
import 'package:presgo_app/models/training_model.dart';

part 'batch_model.g.dart';

@JsonSerializable()
class BatchModel {
  @JsonKey(name: "id")
  final int? id;
  @JsonKey(name: "batch_ke")
  final String? batchKe;
  @JsonKey(name: "trainings")
  final List<TrainingModel>? trainings;

  BatchModel({
    this.id,
    this.batchKe,
    this.trainings,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) => _$BatchModelFromJson(json);

  Map<String, dynamic> toJson() => _$BatchModelToJson(this);
}
