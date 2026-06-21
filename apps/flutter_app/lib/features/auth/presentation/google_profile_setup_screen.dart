import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../profile/profile_provider.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../auth_provider.dart';

/// After Google sign-in, collect required profile fields not provided by OAuth.
class GoogleProfileSetupScreen extends ConsumerStatefulWidget {
  const GoogleProfileSetupScreen({super.key});

  @override
  ConsumerState<GoogleProfileSetupScreen> createState() =>
      _GoogleProfileSetupScreenState();
}

class _GoogleProfileSetupScreenState extends ConsumerState<GoogleProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDateOfBirth;
  String _selectedGender = '';
  String _selectedOrientation = '';
  final _picker = ImagePicker();
  XFile? _selectedPhoto;
  Uint8List? _selectedPhotoBytes;

  static const _genders = ['Man', 'Woman', 'Non-binary', 'Other'];
  static const _orientations = ['Straight', 'Gay', 'Bi', 'Couple', 'Other'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final name = ref.read(authStateProvider).user?.name.trim() ?? '';
      if (name.isNotEmpty) {
        _nameController.text = name;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

    final authNotifier = ref.read(authStateProvider.notifier);
    final profileRepo = ref.read(profileRepositoryProvider);
    final profileNotifier = ref.read(profileStateProvider.notifier);

    try {
      _showSnack('Saving your profile...');

      await profileRepo.updateUserDisplay(name: _nameController.text.trim());
      await profileRepo.patchAccountProfile({
        'bio': '',
        'gender': _selectedGender,
        'preferredGender': _selectedOrientation,
      });

      if (!mounted) return;
      _showSnack('Uploading your photo...');
      await profileNotifier.uploadPhoto(_selectedPhoto!);

      await profileRepo.completeOnboarding();

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

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primaryRed = isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;
    final isBusy = profileState.isPhotoUploading;

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
                Row(
                  children: [
                    GestureDetector(
                      onTap: isBusy
                          ? null
                          : () async {
                              await ref.read(authStateProvider.notifier).logout();
                              if (context.mounted) context.go('/');
                            },
                      child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Complete your profile',
                        style: AppTextStyles.headerSemiBold(color: textColor, fontSize: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'A few details to finish setting up your CasualMeets account.',
                  style: AppTextStyles.bodyRegular(
                    color: textColor.withOpacity(0.55),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),
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
                          child: Text(
                            _dateOfBirthLabel(context),
                            style: AppTextStyles.bodyRegular(
                              color: _selectedDateOfBirth == null
                                  ? textColor.withOpacity(0.55)
                                  : textColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right, color: textColor.withOpacity(0.35)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 28),
                RedButton(
                  label: 'Continue',
                  isLoading: isBusy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
  final Color surfaceColor;
  final Color textColor;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.surfaceColor,
    required this.textColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return TextFormField(
      controller: controller,
      style: TextStyle(color: textColor, fontSize: 15),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withOpacity(0.35), fontSize: 15),
        filled: true,
        fillColor: surfaceColor,
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
