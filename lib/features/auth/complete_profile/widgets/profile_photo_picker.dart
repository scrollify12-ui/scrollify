import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePhotoPicker extends StatelessWidget {
  final VoidCallback onTap;
  final File? imageFile;
  final String? networkImageUrl;

  const ProfilePhotoPicker({
    super.key,
    required this.onTap,
    this.imageFile,
    this.networkImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.divider,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 40,
                ),
              ],
            ),
            child: ClipOval(
              child: _buildImageContent(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.divider,
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
      );
    } else if (networkImageUrl != null && networkImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: networkImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Icon(
          Icons.person,
          size: 64,
          color: Colors.grey,
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.person,
          size: 64,
          color: Colors.grey,
        ),
      );
    } else {
      return const Icon(
        Icons.person,
        size: 64,
        color: Colors.grey,
      );
    }
  }
}
