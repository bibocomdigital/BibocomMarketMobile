import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<String?> pickAppImage(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ajouter une photo',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F4FB),
                  child: Icon(Icons.photo_camera_outlined, color: AppColors.primary),
                ),
                title: const Text(
                  'Prendre une photo',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F4FB),
                  child: Icon(Icons.photo_library_outlined, color: AppColors.primary),
                ),
                title: const Text(
                  'Choisir dans la galerie',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (source == null) return null;

  final file = await ImagePicker().pickImage(
    source: source,
    imageQuality: 80,
  );
  return file?.path;
}
