import 'package:flutter/material.dart';
import '../../utils/Colors.dart';

class UploadProjectUploadingWidget extends StatelessWidget {
  final String uploadStatus;
  final double uploadProgress;

  const UploadProjectUploadingWidget({
    super.key,
    required this.uploadStatus,
    required this.uploadProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
            const SizedBox(height: 30),
            Text(
              uploadStatus,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: uploadProgress,
              backgroundColor: Colors.grey[200],
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            Text(
              '${(uploadProgress * 100).toInt()}%',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
