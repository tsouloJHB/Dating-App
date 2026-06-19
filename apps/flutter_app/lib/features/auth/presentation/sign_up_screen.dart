import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../profile/profile_provider.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedGender = '';
  String _selectedOrientation = '';
  DateTime? _selectedDateOfBirth;
  final _picker = ImagePicker();
  XFile? _selectedPhoto;
  Uint8List? _selectedPhotoBytes;
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  static final RegExp _passwordHasLetter = RegExp(r'[A-Za-z]');
  static final RegExp _passwordHasDigit = RegExp(r'\d');

  static const _genders = ['Man', 'Woman', 'Non-binary', 'Other'];
  static const _orientations = ['Straight', 'Gay', 'Bi', 'Couple', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPhoto == null) {
      _showSnack('Please add your first photo');
      return;
    }
    if (_selectedGender.isEmpty) {
      _showSnack('Please select your gender');
      return;
    }
    if (_selectedOrientation.isEmpty) {
      _showSnack('Please select your sexual orientation');
      return;
    }
    if (_selectedDateOfBirth == null) {
      _showSnack('Please select your date of birth');
      return;
    }

    final age = _calculateAge(_selectedDateOfBirth!);
    if (age < 18) {
      _showSnack('You must be at least 18 years old to continue');
      return;
    }

    // Read all notifiers before any async operations to prevent disposal issues
    final authNotifier = ref.read(authStateProvider.notifier);
    final profileNotifier = ref.read(profileStateProvider.notifier);

    try {
      _showSnack('Creating your account...');

      // Step 1: Sign up
      await authNotifier.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        gender: _selectedGender,
        sexualOrientation: _selectedOrientation,
        age: age,
      );

      // Check if widget is still mounted and user is authenticated
      if (!mounted) return;

      final authState = ref.read(authStateProvider);
      if (!authState.isAuthenticated) {
        if (mounted) {
          _showSnack(authState.error ?? 'Sign up failed. Please try again.');
        }
        return;
      }

      if (mounted) {
        _showSnack('Account created! Uploading your photo...');
      }

      // Step 2: Upload photo
      await profileNotifier.uploadPhoto(_selectedPhoto!);

      if (!mounted) return;

      if (mounted) {
        _showSnack('Photo uploaded! Setting up your profile...');
      }

      // Step 3: Complete setup
      authNotifier.completeProfileSetup();

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: ${e.toString()}');
      }
    }
  }

  int _calculateAge(DateTime dateOfBirth) {
    final today = DateTime.now();
    var age = today.year - dateOfBirth.year;
    final hasHadBirthdayThisYear = today.month > dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day >= dateOfBirth.day);
    if (!hasHadBirthdayThisYear) {
      age -= 1;
    }
    return age;
  }

  String _dateOfBirthLabel(BuildContext context) {
    final selectedDate = _selectedDateOfBirth;
    if (selectedDate == null) {
      return 'Select your date of birth';
    }
    return MaterialLocalizations.of(context).formatMediumDate(selectedDate);
  }

  Future<void> _pickDateOfBirth() async {
    final today = DateTime.now();
    final latestAllowed = DateTime(today.year - 18, today.month, today.day);
    final initialDate = _selectedDateOfBirth ?? DateTime(today.year - 24, today.month, today.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(latestAllowed) ? latestAllowed : initialDate,
      firstDate: DateTime(today.year - 80, 1, 1),
      lastDate: latestAllowed,
      helpText: 'Select your date of birth',
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedDateOfBirth = picked);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final pickedBytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedPhoto = picked;
      _selectedPhotoBytes = pickedBytes;
    });
  }

  Future<void> _showPhotoSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take photo'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _pickPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.darkPrimaryAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final profileState = ref.watch(profileStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primaryRed = isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;
    final isBusy = authState.isLoading || profileState.isPhotoUploading;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button + header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.canPop() ? context.pop() : context.go('/'),
                      child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Create Account',
                      style: AppTextStyles.headerSemiBold(color: textColor, fontSize: 22),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Text(
                    'Find your match today.',
                    style: AppTextStyles.bodyRegular(
                      color: textColor.withOpacity(0.55),
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Center(
                  child: AppBrandLogo(size: 72, borderRadius: 22),
                ),
                const SizedBox(height: 28),

                // Name
                _Label('Name', textColor),
                const SizedBox(height: 8),
                _InputField(
                  controller: _nameController,
                  hint: 'Your name',
                  surfaceColor: surfaceColor,
                  textColor: textColor,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Name is required';
                    if (value.length < 2) return 'Name must be at least 2 characters';
                    if (value.length > 40) return 'Name must be 40 characters or less';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // First photo upload
                _Label('First Photo', textColor),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: isBusy ? null : _showPhotoSheet,
                  child: Container(
                    height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _selectedPhoto == null
                            ? textColor.withOpacity(0.1)
                            : primaryRed.withOpacity(0.5),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _selectedPhoto == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined,
                                  color: textColor.withOpacity(0.5), size: 28),
                              const SizedBox(height: 10),
                              Text(
                                'Add your first photo',
                                style: AppTextStyles.bodyRegular(
                                  color: textColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Required to complete sign up',
                                style: AppTextStyles.bodyRegular(
                                  color: textColor.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              if (_selectedPhotoBytes != null)
                                Image.memory(
                                  _selectedPhotoBytes!,
                                  fit: BoxFit.cover,
                                ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _selectedPhoto = null;
                                    _selectedPhotoBytes = null;
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.55),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Email
                _Label('Email', textColor),
                const SizedBox(height: 8),
                _InputField(
                  controller: _emailController,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  surfaceColor: surfaceColor,
                  textColor: textColor,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Email is required';
                    if (!_emailRegex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password
                _Label('Password', textColor),
                const SizedBox(height: 8),
                _InputField(
                  controller: _passwordController,
                  hint: 'Min. 8 characters',
                  obscureText: _obscurePassword,
                  surfaceColor: surfaceColor,
                  textColor: textColor,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: textColor.withOpacity(0.5),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    final value = v ?? '';
                    if (value.isEmpty) return 'Password is required';
                    if (value.length < 8) return 'Use at least 8 characters';
                    if (!_passwordHasLetter.hasMatch(value)) {
                      return 'Include at least one letter';
                    }
                    if (!_passwordHasDigit.hasMatch(value)) {
                      return 'Include at least one number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _Label('Confirm Password', textColor),
                const SizedBox(height: 8),
                _InputField(
                  controller: _confirmPasswordController,
                  hint: 'Re-enter password',
                  obscureText: _obscurePassword,
                  surfaceColor: surfaceColor,
                  textColor: textColor,
                  validator: (v) {
                    final value = v ?? '';
                    if (value.isEmpty) return 'Please confirm your password';
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Date of birth
                _Label('Date of Birth', textColor),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: isBusy ? null : _pickDateOfBirth,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _selectedDateOfBirth == null
                            ? textColor.withOpacity(0.08)
                            : primaryRed.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cake_outlined, color: textColor.withOpacity(0.55), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _dateOfBirthLabel(context),
                                style: AppTextStyles.bodyRegular(
                                  color: _selectedDateOfBirth == null
                                      ? textColor.withOpacity(0.55)
                                      : textColor,
                                  fontSize: 15,
                                ),
                              ),
                              if (_selectedDateOfBirth != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Age ${_calculateAge(_selectedDateOfBirth!)}',
                                  style: AppTextStyles.bodyRegular(
                                    color: textColor.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: textColor.withOpacity(0.35)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Gender picker
                _Label('Gender', textColor),
                const SizedBox(height: 10),
                _ChipPicker(
                  options: _genders,
                  selected: _selectedGender,
                  primaryRed: primaryRed,
                  surfaceColor: surfaceColor,
                  textColor: textColor,
                  onSelect: (v) => setState(() => _selectedGender = v),
                ),

                const SizedBox(height: 20),

                // Orientation picker
                _Label('Sexual Orientation', textColor),
                const SizedBox(height: 10),
                _ChipPicker(
                  options: _orientations,
                  selected: _selectedOrientation,
                  primaryRed: primaryRed,
                  surfaceColor: surfaceColor,
                  textColor: textColor,
                  onSelect: (v) => setState(() => _selectedOrientation = v),
                ),

                const SizedBox(height: 16),

                // Error banner
                if (authState.error != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primaryRed.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: primaryRed, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _friendlyError(authState.error!),
                            style: AppTextStyles.bodyRegular(
                              color: primaryRed,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 8),

                // Submit
                RedButton(
                  label: authState.profileSetupPending
                      ? 'Upload Photo to Finish'
                      : 'Create Account',
                  isLoading: isBusy,
                  onPressed: _submit,
                ),

                const SizedBox(height: 28),

                // Sign in link
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/sign-in'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: AppTextStyles.bodyRegular(
                          color: textColor.withOpacity(0.6),
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: AppTextStyles.bodyRegular(
                              color: primaryRed,
                              fontSize: 14,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _friendlyError(String raw) {
    final normalized = raw.toLowerCase();
    if (normalized.contains('already registered') ||
        normalized.contains('already exists') ||
        normalized.contains('409')) {
      return 'This email is already registered. Try signing in.';
    }
    if (normalized.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (normalized.contains('no internet') || normalized.contains('network')) {
      return 'No internet connection. Check your network and try again.';
    }
    if (normalized.contains('too many')) {
      return 'Too many attempts. Please wait and try again.';
    }
    return raw.trim().isEmpty ? 'Sign up failed. Please try again.' : raw;
  }
}

// ──────────────────────────────────────────────
// Helper widgets
// ──────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyRegular(color: color, fontSize: 14),
    );
  }
}

class _ChipPicker extends StatelessWidget {
  final List<String> options;
  final String selected;
  final Color primaryRed;
  final Color surfaceColor;
  final Color textColor;
  final ValueChanged<String> onSelect;

  const _ChipPicker({
    required this.options,
    required this.selected,
    required this.primaryRed,
    required this.surfaceColor,
    required this.textColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final isActive = selected == opt;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? primaryRed : surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isActive ? primaryRed : textColor.withOpacity(0.1),
              ),
            ),
            child: Text(
              opt,
              style: AppTextStyles.bodyRegular(
                color: isActive ? Colors.white : textColor,
                fontSize: 14,
              ).copyWith(fontWeight: isActive ? FontWeight.w600 : FontWeight.normal),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Color surfaceColor;
  final Color textColor;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.surfaceColor,
    required this.textColor,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor, fontSize: 15),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withOpacity(0.35), fontSize: 15),
        filled: true,
        fillColor: surfaceColor,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: textColor.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorStyle: TextStyle(color: accent, fontSize: 12),
      ),
    );
  }
}
