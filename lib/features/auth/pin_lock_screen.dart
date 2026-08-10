import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/auth_repository.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  String _enteredPin = '';
  bool _isError = false;
  String? _storedPin;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoredPin();
  }

  Future<void> _loadStoredPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedPin = prefs.getString('app_pin');
      _isLoading = false;
    });
  }

  void _onKeyPress(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _isError = false;
        _enteredPin += digit;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _isError = false;
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    if (_enteredPin == _storedPin) {
      ref.read(pinUnlockedProvider.notifier).state = true;
      if (mounted) {
        context.go('/');
      }
    } else {
      setState(() {
        _isError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PIN salah, silakan coba lagi!',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.expense,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _enteredPin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryDark)),
      );
    }

    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // App Logo Header
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F0E6B4F),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.lock_rounded,
                      color: AppColors.primaryDark,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Selamat Datang Kembali',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan PIN Keamanan untuk ${user?.displayName ?? "Pengguna"}',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // PIN Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? (_isError ? AppColors.expense : AppColors.primaryDark)
                          : Colors.white,
                      border: Border.all(
                        color: _isError
                            ? AppColors.expense
                            : (isFilled ? AppColors.primaryDark : AppColors.divider),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(flex: 2),

              // Numpad 0-9
              Container(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  children: [
                    _buildNumpadRow(['1', '2', '3']),
                    const SizedBox(height: 16),
                    _buildNumpadRow(['4', '5', '6']),
                    const SizedBox(height: 16),
                    _buildNumpadRow(['7', '8', '9']),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: IconButton(
                            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
                            onPressed: () async {
                              ref.read(currentUserProvider.notifier).setUser(null);
                              context.go('/login');
                            },
                            tooltip: 'Keluar',
                          ),
                        ),
                        _buildNumpadButton('0'),
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: IconButton(
                            icon: const Icon(Icons.backspace_outlined, color: AppColors.primaryDark),
                            onPressed: _onBackspace,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildNumpadButton(d)).toList(),
    );
  }

  Widget _buildNumpadButton(String digit) {
    return InkWell(
      onTap: () => _onKeyPress(digit),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.primaryDark),
        ),
      ),
    );
  }
}
