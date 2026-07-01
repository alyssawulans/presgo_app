// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BatchModel _$BatchModelFromJson(Map<String, dynamic> json) => BatchModel(
  id: (json['id'] as num?)?.toInt(),
  batchKe: json['batch_ke'] as String?,
  trainings: (json['trainings'] as List<dynamic>?)
      ?.map((e) => TrainingModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BatchModelToJson(BatchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'batch_ke': instance.batchKe,
      'trainings': instance.trainings,
    };
