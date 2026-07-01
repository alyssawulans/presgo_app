import 'package:json_annotation/json_annotation.dart';
import 'package:presgo_app/models/batch_model.dart';
import 'package:presgo_app/models/training_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: "id")
  final int? id;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "email")
  final String? email;
  @JsonKey(name: "jenis_kelamin")
  final String? jenisKelamin;
  @JsonKey(name: "profile_photo")
  final String? profilePhoto;
  @JsonKey(name: "batch_id")
  final dynamic batchId;
  @JsonKey(name: "training_id")
  final dynamic trainingId;
  @JsonKey(name: "created_at")
  final String? createdAt;
  @JsonKey(name: "batch")
  final BatchModel? batch;
  @JsonKey(name: "training")
  final TrainingModel? training;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.jenisKelamin,
    this.profilePhoto,
    this.batchId,
    this.trainingId,
    this.createdAt,
    this.batch,
    this.training,
  });

  String get batchName => batch?.batchKe ?? '-';
  String get trainingName => training?.title ?? '-';

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
