// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  email: json['email'] as String?,
  jenisKelamin: json['jenis_kelamin'] as String?,
  profilePhoto: json['profile_photo'] as String?,
  batchId: json['batch_id'],
  trainingId: json['training_id'],
  createdAt: json['created_at'] as String?,
  batch: json['batch'] == null
      ? null
      : BatchModel.fromJson(json['batch'] as Map<String, dynamic>),
  training: json['training'] == null
      ? null
      : TrainingModel.fromJson(json['training'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'jenis_kelamin': instance.jenisKelamin,
  'profile_photo': instance.profilePhoto,
  'batch_id': instance.batchId,
  'training_id': instance.trainingId,
  'created_at': instance.createdAt,
  'batch': instance.batch,
  'training': instance.training,
};
