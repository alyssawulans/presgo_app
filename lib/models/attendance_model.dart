import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

@JsonSerializable()
class AttendanceModel {
  @JsonKey(name: "id")
  final int? id;
  @JsonKey(name: "attendance_date")
  final String? attendanceDate;
  @JsonKey(name: "check_in_time")
  final String? checkInTime;
  @JsonKey(name: "check_out_time")
  final String? checkOutTime;
  @JsonKey(name: "check_in_lat")
  final dynamic checkInLat;
  @JsonKey(name: "check_in_lng")
  final dynamic checkInLng;
  @JsonKey(name: "check_out_lat")
  final dynamic checkOutLat;
  @JsonKey(name: "check_out_lng")
  final dynamic checkOutLng;
  @JsonKey(name: "check_in_address")
  final String? checkInAddress;
  @JsonKey(name: "check_out_address")
  final String? checkOutAddress;
  @JsonKey(name: "status")
  final String? status;
  @JsonKey(name: "alasan_izin")
  final String? alasanIzin;

  AttendanceModel({
    this.id,
    this.attendanceDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    this.checkInAddress,
    this.checkOutAddress,
    this.status,
    this.alasanIzin,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => _$AttendanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);
}
