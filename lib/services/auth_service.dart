import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:presgo_app/models/login_response.dart';

part 'auth_service.g.dart';

@RestApi(baseUrl: 'https://appabsensi.mobileprojp.com')
abstract class AuthService {
  factory AuthService(Dio dio, {String baseUrl}) = _AuthService;

  @POST('/api/register')
  Future<LoginResponse> register(@Body() Map<String, dynamic> body);

  @POST('/api/login')
  Future<LoginResponse> login(@Body() Map<String, dynamic> body);

  @GET('/api/profile')
  Future<dynamic> getProfile();

  @PUT('/api/profile')
  Future<dynamic> editProfile(@Body() Map<String, dynamic> body);

  @PUT('/api/profile/photo')
  Future<dynamic> editProfilePhoto(@Body() Map<String, dynamic> body);

  @GET('/api/batches')
  Future<dynamic> getBatches();

  @GET('/api/trainings')
  Future<dynamic> getTrainings();

  @POST('/api/absen/check-in')
  Future<dynamic> checkIn(@Body() Map<String, dynamic> body);

  @POST('/api/absen/check-out')
  Future<dynamic> checkOut(@Body() Map<String, dynamic> body);

  @GET('/api/absen/today')
  Future<dynamic> getTodayAttendance(@Query('attendance_date') String date);

  @GET('/api/absen/history')
  Future<dynamic> getHistory(
    @Query('start') String? start,
    @Query('end') String? end,
  );

  @GET('/api/absen/stats')
  Future<dynamic> getStats(
    @Query('start') String? start,
    @Query('end') String? end,
    @Query('year') String? year,
  );

  @DELETE('/api/absen/{id}')
  Future<void> deleteAttendance(@Path('id') int id);
}
