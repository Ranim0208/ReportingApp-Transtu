import 'dart:io';

class FileValidator {
  FileValidator._();

  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB
  static const int maxTotalSizeBytes = 25 * 1024 * 1024; // 25 MB
  static const int maxFileCount = 5;

  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

  static String? validateFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(ext)) {
      return 'Type non autorisé : utilisez JPG, PNG ou PDF.';
    }
    final size = file.lengthSync();
    if (size > maxFileSizeBytes) {
      return 'Fichier trop volumineux (max 10 Mo).';
    }
    return null;
  }

  static String? validateAll(List<File> files) {
    if (files.length > maxFileCount) {
      return 'Maximum 5 fichiers autorisés.';
    }
    final total = files.fold<int>(0, (sum, f) => sum + f.lengthSync());
    if (total > maxTotalSizeBytes) {
      return 'Taille totale trop grande (max 25 Mo).';
    }
    for (final file in files) {
      final error = validateFile(file);
      if (error != null) return error;
    }
    return null;
  }
}
