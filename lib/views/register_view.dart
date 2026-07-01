import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:presgo_app/models/batch_model.dart';
import 'package:presgo_app/models/training_model.dart';
import 'package:presgo_app/services/api_service.dart';
import 'package:presgo_app/services/storage_service.dart';
import 'package:presgo_app/views/login_view.dart';
import 'package:presgo_app/views/main_navigation_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  List<BatchModel> _batches = [];
  List<TrainingModel> _trainings = [];

  int? _selectedBatchId;
  int? _selectedTrainingId;
  String _selectedGender = 'L'; // L or P

  bool _isLoadingDropdowns = true;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final results = await Future.wait([
        ApiService.instance.getBatches(),
        ApiService.instance.getTrainings(),
      ]);

      setState(() {
        _batches = results[0] as List<BatchModel>;
        _trainings = results[1] as List<TrainingModel>;
        _isLoadingDropdowns = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil data pilihan: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _isLoadingDropdowns = false;
      });
    }
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih batch terlebih dahulu.'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_selectedTrainingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih training terlebih dahulu.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final response = await ApiService.instance.register(
        name: name,
        email: email,
        password: password,
        gender: _selectedGender,
        batchId: _selectedBatchId!,
        trainingId: _selectedTrainingId!,
      );

      if (response.data != null && response.data!.token != null) {
        final token = response.data!.token!;
        await StorageService.saveToken(token);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Selamat datang.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationView()),
        );
      } else {
        throw Exception(response.message ?? 'Registrasi gagal, silakan coba lagi.');
      }
    } catch (e) {
      if (!mounted) return;
      String errMsg = e.toString().replaceAll('Exception:', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errMsg),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF080C24) : const Color(0xFFF4F7FC);
    final Color cardColor = isDark ? const Color(0xFF131738) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextColor = isDark ? const Color(0xFF90A3BF) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF2E66FF).withOpacity(0.15) : Colors.grey.withOpacity(0.2);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Glows
          if (isDark) ...[
            Positioned(
              top: -120,
              left: -50,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2E66FF).withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8F30FF).withOpacity(0.1),
                ),
              ),
            ),
          ],
          SafeArea(
            child: Center(
              child: _isLoadingDropdowns
                  ? const CircularProgressIndicator(color: Color(0xFF2E66FF))
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            // Lottie Mascot Animation
                            SizedBox(
                              height: 130,
                              width: 130,
                              child: Lottie.asset(
                                'assets/animations/logomaskot.json',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8F30FF).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      size: 50,
                                      color: Color(0xFF8F30FF),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Header Text
                            Text(
                              'Buat Akun Baru',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Daftarkan akun untuk mulai menggunakan aplikasi',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: subTextColor,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Glassmorphic Form Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cardColor.withOpacity(isDark ? 0.8 : 1.0),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nama Lengkap input
                                  _buildTextField(
                                    controller: _nameController,
                                    label: 'Nama Lengkap',
                                    hint: 'Masukkan nama lengkap',
                                    prefixIcon: Icons.person_outline_rounded,
                                    textColor: textColor,
                                    subTextColor: subTextColor,
                                    cardColor: cardColor,
                                    borderColor: borderColor,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Nama tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 18),

                                  // Email input
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    hint: 'Masukkan alamat email',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    textColor: textColor,
                                    subTextColor: subTextColor,
                                    cardColor: cardColor,
                                    borderColor: borderColor,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Email tidak boleh kosong';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Format email tidak valid';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 18),

                                  // Batch Dropdown
                                  _buildDropdownField<int?>(
                                    label: 'Batch',
                                    hint: 'Pilih batch',
                                    value: _selectedBatchId,
                                    prefixIcon: Icons.class_outlined,
                                    textColor: textColor,
                                    subTextColor: subTextColor,
                                    cardColor: cardColor,
                                    borderColor: borderColor,
                                    items: _batches.map((batch) {
                                      return DropdownMenuItem<int?>(
                                        value: batch.id,
                                        child: Text(batch.batchKe ?? '', style: TextStyle(color: textColor, fontSize: 13)),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedBatchId = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 18),

                                  // Training Dropdown
                                  _buildDropdownField<int?>(
                                    label: 'Training',
                                    hint: 'Pilih training',
                                    value: _selectedTrainingId,
                                    prefixIcon: Icons.workspace_premium_outlined,
                                    textColor: textColor,
                                    subTextColor: subTextColor,
                                    cardColor: cardColor,
                                    borderColor: borderColor,
                                    items: _trainings.map((t) {
                                      return DropdownMenuItem<int?>(
                                        value: t.id,
                                        child: Text(
                                          t.title ?? '',
                                          style: TextStyle(color: textColor, fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedTrainingId = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 18),

                                  // Gender Dropdown
                                  _buildDropdownField<String>(
                                    label: 'Jenis Kelamin',
                                    hint: 'Pilih jenis kelamin',
                                    value: _selectedGender,
                                    prefixIcon: Icons.wc_rounded,
                                    textColor: textColor,
                                    subTextColor: subTextColor,
                                    cardColor: cardColor,
                                    borderColor: borderColor,
                                    items: [
                                      DropdownMenuItem(
                                        value: 'L',
                                        child: Text('Laki-laki', style: TextStyle(color: textColor, fontSize: 13)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'P',
                                        child: Text('Perempuan', style: TextStyle(color: textColor, fontSize: 13)),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedGender = value ?? 'L';
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 18),

                                  // Password input
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    hint: 'Masukkan password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword,
                                    textColor: textColor,
                                    subTextColor: subTextColor,
                                    cardColor: cardColor,
                                    borderColor: borderColor,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: subTextColor,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password tidak boleh kosong';
                                      }
                                      if (value.length < 6) {
                                        return 'Password minimal 6 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 18),

                                  // Konfirmasi Password input
                                  _buildTextField(
                                    controller: _confirmPasswordController,
                                    label: 'Konfirmasi Password',
                                    hint: 'Ulangi password Anda',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword,
                                    textColor: textColor,
                                    subTextColor: subTextColor,
                                    cardColor: cardColor,
                                    borderColor: borderColor,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: subTextColor,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Konfirmasi password tidak boleh kosong';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Password tidak cocok';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 28),

                                  // Register Button
                                  Container(
                                    width: double.infinity,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF2E66FF), Color(0xFF8F30FF)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF8F30FF).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        )
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: _isSubmitting ? null : _register,
                                        child: Center(
                                          child: _isSubmitting
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.5,
                                                  ),
                                                )
                                              : const Text(
                                                  'Daftar',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Already have account? Login link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sudah punya akun? ',
                                  style: TextStyle(color: subTextColor, fontSize: 13),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginView()),
                                    );
                                  },
                                  child: const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      color: Color(0xFF2E66FF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    required Color textColor,
    required Color subTextColor,
    required Color cardColor,
    required Color borderColor,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: subTextColor.withOpacity(0.8),
            ),
            filled: true,
            fillColor: cardColor.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(width: 1.5, color: Color(0xFF2E66FF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFF2E66FF),
              size: 18,
            ),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required T? value,
    required IconData prefixIcon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required Color textColor,
    required Color subTextColor,
    required Color cardColor,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            style: TextStyle(color: textColor, fontSize: 13),
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                prefixIcon,
                color: const Color(0xFF2E66FF),
                size: 18,
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
            ),
            hint: Text(
              hint,
              style: TextStyle(color: subTextColor.withOpacity(0.8), fontSize: 12),
            ),
            dropdownColor: cardColor,
            icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF2E66FF)),
            items: items,
            onChanged: onChanged,
            validator: (val) {
              if (val == null) {
                return 'Pilihan wajib diisi';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
