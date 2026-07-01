import 'package:dio/dio.dart';
import 'package:presgo_app/models/batch_model.dart';
import 'package:presgo_app/models/training_model.dart';
import 'package:presgo_app/models/user_model.dart';
import 'package:presgo_app/models/attendance_model.dart';
import 'package:presgo_app/models/login_response.dart';
import 'package:presgo_app/services/auth_service.dart';
import 'package:presgo_app/services/dio_client.dart';

class ApiService {
  static final ApiService instance = ApiService._();
  late final AuthService _authService;

  ApiService._() {
    _authService = AuthService(createDioClient());
  }

  /// Convert any thrown error into a clean, user-friendly Exception message.
  Exception _handleError(Object e) {
    if (e is DioException) {
      // message was already extracted by our onResponse interceptor
      final msg = e.message;
      if (msg != null && msg.isNotEmpty) {
        return Exception(msg);
      }
      // Fallback: check response body directly
      final data = e.response?.data;
      if (data is Map) {
        for (final key in ['message', 'error', 'msg']) {
          if (data[key] != null) return Exception(data[key].toString());
        }
      }
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return Exception('Koneksi timeout. Periksa jaringan Anda.');
        case DioExceptionType.connectionError:
          return Exception('Tidak dapat terhubung ke server. Periksa koneksi internet.');
        default:
          return Exception('Terjadi kesalahan. Coba lagi.');
      }
    }
    return Exception(e.toString().replaceAll('Exception:', '').trim());
  }

  // 1. REGISTER
  Future<LoginResponse> register({
    required String name,
    required String email,
    required String password,
    required String gender,
    required int batchId,
    required int trainingId,
  }) async {
    try {
      return await _authService.register({
        'name': name,
        'email': email,
        'password': password,
        'jenis_kelamin': gender,
        'profile_photo': '',
        'batch_id': batchId,
        'training_id': trainingId,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 2. LOGIN
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.login({
        'email': email,
        'password': password,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 3. GET PROFILE
  Future<UserModel> getProfile() async {
    try {
      final response = await _authService.getProfile();
      final data = response['data'];
      return UserModel.fromJson(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 4. EDIT PROFILE
  Future<UserModel> editProfile({required String name, required String email}) async {
    try {
      final response = await _authService.editProfile({
        'name': name,
        'email': email,
      });
      final data = response['data'];
      return UserModel.fromJson(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 4b. EDIT PROFILE PHOTO
  Future<UserModel> editProfilePhoto({required String base64Image}) async {
    try {
      final response = await _authService.editProfilePhoto({
        'profile_photo': base64Image,
      });
      final data = response['data'];
      return UserModel.fromJson(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 5. GET BATCHES
  Future<List<BatchModel>> getBatches() async {
    try {
      final response = await _authService.getBatches();
      final list = response['data'] as List;
      return list.map((b) => BatchModel.fromJson(b)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 6. GET TRAININGS
  Future<List<TrainingModel>> getTrainings() async {
    try {
      final response = await _authService.getTrainings();
      final list = response['data'] as List;
      return list.map((t) => TrainingModel.fromJson(t)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 7. ABSEN CHECK IN
  Future<AttendanceModel> checkIn({
    required String date,
    required String time,
    required double lat,
    required double lng,
    required String address,
    required String status,
    String? alasanIzin,
  }) async {
    try {
      final response = await _authService.checkIn({
        'attendance_date': date,
        'check_in': time,
        'check_in_lat': lat,
        'check_in_lng': lng,
        'check_in_address': address,
        'status': status,
        if (alasanIzin != null) 'alasan_izin': alasanIzin,
      });
      final data = response['data'];
      return AttendanceModel.fromJson(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 8. ABSEN CHECK OUT
  Future<AttendanceModel> checkOut({
    required String date,
    required String time,
    required double lat,
    required double lng,
    required String address,
  }) async {
    try {
      final response = await _authService.checkOut({
        'attendance_date': date,
        'check_out': time,
        'check_out_lat': lat,
        'check_out_lng': lng,
        'check_out_location': '$lat,$lng',
        'check_out_address': address,
      });
      final data = response['data'];
      return AttendanceModel.fromJson(data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 9. ABSEN TODAY
  Future<AttendanceModel?> getTodayAttendance(String date) async {
    try {
      final response = await _authService.getTodayAttendance(date);
      if (response['data'] == null) return null;
      return AttendanceModel.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }

  // 10. HISTORY ABSEN
  Future<List<AttendanceModel>> getHistory({String? start, String? end}) async {
    try {
      final response = await _authService.getHistory(start, end);
      final data = response['data'];
      if (data is List) {
        return data.map((a) => AttendanceModel.fromJson(a)).toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 11. STATS ABSEN
  Future<Map<String, dynamic>> getStats({String? start, String? end, String? year}) async {
    try {
      final response = await _authService.getStats(start, end, year);
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 12. DELETE ABSEN
  Future<void> deleteAttendance(int id) async {
    try {
      await _authService.deleteAttendance(id);
    } catch (e) {
      throw _handleError(e);
    }
  }
}
