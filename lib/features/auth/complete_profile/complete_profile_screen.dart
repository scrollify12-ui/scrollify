import 'dart:io';
import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../repository/profile_repository.dart';
import '../../../../repository/auth_repository.dart';
import '../../../../core/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/profile_photo_picker.dart';
import 'widgets/custom_text_field.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _instagramController = TextEditingController();

  File? _profileImageFile;
  String? _googlePhotoUrl;
  bool _isLoading = false;
  
  // Validation tracking
  bool _isNameValid = false;
  bool _isUsernameLocalValid = false;
  bool _isUsernameAvailable = false;
  
  Timer? _debounce;
  String? _usernameStatusMessage;
  Color? _usernameStatusColor;
  bool _isCheckingUsername = false;

  @override
  void initState() {
    super.initState();
    _loadGoogleData();
  }

  void _loadGoogleData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        _nameController.text = user.displayName!;
        _generateAndCheckUsername(user.displayName!);
      }
      if (user.photoURL != null) {
        setState(() {
          _googlePhotoUrl = user.photoURL;
        });
      }
      _validateForm();
    }
  }

  Future<void> _generateAndCheckUsername(String fullName) async {
    final baseUsername = fullName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    if (baseUsername.isEmpty) return;
    
    bool isAvailable = false;
    String candidate = baseUsername;
    
    if (candidate.length < 5) candidate = '${candidate}user';
    if (!RegExp(r'^[a-z]').hasMatch(candidate)) candidate = 'user$candidate';
    
    int attempt = 0;
    while (!isAvailable && attempt < 5) {
       try {
         isAvailable = await ref.read(profileRepositoryProvider).isUsernameUnique(candidate);
         if (isAvailable) {
           if (mounted) {
             setState(() {
               _usernameController.text = candidate;
               _isUsernameAvailable = true;
               _usernameStatusMessage = '✅ Suggested username available';
               _usernameStatusColor = Colors.green;
               _isUsernameLocalValid = true;
             });
           }
           break;
         } else {
           attempt++;
           candidate = attempt == 1 ? '${baseUsername}01' : '${baseUsername}${attempt}';
         }
       } catch (e) {
         break;
       }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isNameValid = RegExp(r'^[a-zA-Z\s]{2,50}$').hasMatch(_nameController.text.trim());
      _isUsernameLocalValid = RegExp(r'^[a-z][a-z0-9_]{4,19}$').hasMatch(_usernameController.text);
    });
  }

  void _checkUsernameAvailability(String username) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    setState(() {
      _isCheckingUsername = true;
      _usernameStatusMessage = 'Checking availability...';
      _usernameStatusColor = AppColors.textSecondary;
      _isUsernameAvailable = false;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        debugPrint('[Username Validation] Checking availability for "$username"');
        final isAvailable = await ref.read(profileRepositoryProvider).isUsernameUnique(username);
        
        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            if (isAvailable) {
              _usernameStatusMessage = '✅ Username available';
              _usernameStatusColor = Colors.green;
              _isUsernameAvailable = true;
            } else {
              _usernameStatusMessage = '❌ This username is already taken.';
              _usernameStatusColor = Colors.redAccent;
              _isUsernameAvailable = false;
            }
          });
        }
      } catch (e) {
        debugPrint('[Username Validation] API Error: $e');
        if (mounted) {
          setState(() {
            _isCheckingUsername = false;
            // Catch the exact exception message and show it instead of a generic one.
            String errMsg = e.toString();
            // Clean up the exception prefix if present
            if (errMsg.startsWith('Exception: ')) {
              errMsg = errMsg.replaceFirst('Exception: ', '');
            }
            _usernameStatusMessage = 'Error: $errMsg';
            _usernameStatusColor = Colors.orangeAccent;
            _isUsernameAvailable = false;
          });
        }
      }
    });
  }

  bool get _isFormReady => _isNameValid && _isUsernameLocalValid && _isUsernameAvailable && !_isLoading && !_isCheckingUsername;

  Future<Permission> _galleryPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return Permission.photos;
      } else {
        return Permission.storage;
      }
    }
    return Permission.photos;
  }

  Future<void> _pickImage(ImageSource source) async {
    final Permission permission =
        source == ImageSource.camera ? Permission.camera : await _galleryPermission();

    PermissionStatus status = await permission.status;

    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(source);
      return;
    }

    if (!status.isGranted) {
      status = await permission.request();
    }

    if (status.isGranted || status.isLimited) {
      await _openPicker(source);
    } else if (status.isPermanentlyDenied) {
      if (mounted) _showPermanentlyDeniedDialog(source);
    }
  }

  void _showPermanentlyDeniedDialog(ImageSource source) {
    final label = source == ImageSource.camera ? 'Camera' : 'Photos';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Permission required to access photos.',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Scrollify needs $label access to set your profile photo. '
          'Please enable it in App Settings.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPicker(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Profile Photo',
              toolbarColor: AppColors.background,
              toolbarWidgetColor: AppColors.primary,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: true,
            ),
            IOSUiSettings(
              title: 'Crop Profile Photo',
              aspectRatioLockEnabled: true,
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _profileImageFile = File(croppedFile.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo (Camera)', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_isFormReady) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final username = _usernameController.text;

      // Final safety check before submission
      if (!_isUsernameAvailable) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Upload profile photo if selected
      String? photoUrl = _googlePhotoUrl;
      if (_profileImageFile != null) {
        photoUrl = await profileRepo.uploadProfilePhoto(_profileImageFile!);
      }

      // Format Instagram handle
      String? insta = _instagramController.text.trim();
      if (insta.startsWith('@')) insta = insta.substring(1);
      if (insta.isEmpty) insta = null;

      // Complete profile
      await profileRepo.completeProfile(
        fullName: _nameController.text.trim(),
        username: username,
        instagramHandle: insta,
        profilePhotoUrl: photoUrl,
      );

      if (mounted) {
        ref.invalidate(userProvider);
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete profile: $e')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            await ref.read(authRepositoryProvider).logout();
                            if (mounted) context.go('/login');
                          },
                  ),
                  const Expanded(
                    child: Text(
                      'Complete Your Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      
                      // Profile Photo
                      ProfilePhotoPicker(
                        imageFile: _profileImageFile,
                        networkImageUrl: _googlePhotoUrl,
                        onTap: _isLoading ? () {} : _showImagePickerOptions,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Add Profile Photo',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Form Fields
                      CustomTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hintText: 'Enter your full name',
                        icon: Icons.person_outline,
                        onChanged: (_) => _validateForm(),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return 'Please enter your full name';
                          if (text.length < 2 || text.length > 50) return 'Must be between 2 and 50 characters';
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) return 'Only letters and spaces allowed';
                          return null;
                        },
                      ),
                      CustomTextField(
                        controller: _usernameController,
                        label: 'Username',
                        hintText: 'Enter your username',
                        icon: Icons.alternate_email,
                        onChanged: (val) {
                          final lower = val.toLowerCase().replaceAll(' ', '');
                          if (val != lower) {
                            _usernameController.value = TextEditingValue(
                              text: lower,
                              selection: TextSelection.collapsed(offset: lower.length),
                            );
                          }
                          _validateForm();
                          
                          if (_isUsernameLocalValid) {
                            _checkUsernameAvailability(_usernameController.text);
                          } else {
                            setState(() {
                              _usernameStatusMessage = null;
                              _isUsernameAvailable = false;
                            });
                          }
                        },
                        validator: (value) {
                          final text = value ?? '';
                          if (text.isEmpty) return 'Please enter a username';
                          if (text.length < 5 || text.length > 20) return 'Must be between 5 and 20 characters';
                          if (!RegExp(r'^[a-z]').hasMatch(text)) return 'Must start with a letter';
                          if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(text)) return 'Only lowercase letters, numbers, and underscores allowed';
                          return null;
                        },
                      ),
                      if (_usernameStatusMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _usernameStatusMessage!,
                              style: TextStyle(
                                color: _usernameStatusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      CustomTextField(
                        controller: _instagramController,
                        label: 'Instagram Handle',
                        hintText: '@yourusername',
                        icon: Icons.camera_alt_outlined,
                        isOptional: true,
                        onChanged: (val) {
                          if (val.startsWith('@')) {
                            final withoutAt = val.substring(1);
                            _instagramController.value = TextEditingValue(
                              text: withoutAt,
                              selection: TextSelection.collapsed(offset: withoutAt.length),
                            );
                          }
                        },
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isNotEmpty) {
                            if (text.length > 30) return 'Max 30 characters';
                            if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(text)) return 'Invalid format';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Visible to others on leaderboard',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Fixed Footer Button
      bottomSheet: Container(
        color: Colors.black.withValues(alpha: 0.9),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isFormReady ? _submit : null,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Complete Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
