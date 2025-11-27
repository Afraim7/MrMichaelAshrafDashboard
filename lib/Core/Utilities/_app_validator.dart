
class AppValidator {
  
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل بريدك الألكتروني';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'قم بأدخال بريد الكتروني صحيح';
    }
    
    return null;
  }

  static String? validateEmailAlternative(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'أدخل بريدك الألكتروني';
    
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(v)) return 'قم بإدخال بريد إلكتروني صحيح';
    
    return null;
  }

  
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل رقم هاتفك';
    }
    final phoneRegex = RegExp(r'^(\+201|01|00201)[0-2,5]{1}[0-9]{8}');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'قم بأدخال رقم هاتف صحيح';
    }
    return null;
  }
  
  static String? validatePasswordSignup(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'قم بأدخال كلمة السر';
    }
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    if (!passwordRegex.hasMatch(value.trim())) {
      return 'كلمة السر يجب ان تتكون من 8 احرف وارقام علي الأقل';
    }
    
    return null;
  }

  static String? validatePasswordLogin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ادخل كلمة السر';
    }
    return null;
  }

  static String? validatePasswordConfirmation(String? value, String originalPassword) {
    if (value == null || value.trim().isEmpty) {
      return 'يجب تأكيد كلمة السر';
    }
    if (value != originalPassword) {
      return 'يجب أن تتطابق كلمة السر';
    }
    return null;
  }

  static String? validateCurrentPassword(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'أدخل كلمة السر الحالية';
    return null;
  }

  static String? validateNewPassword(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'أدخل كلمة السر الجديدة';
    if (v.length < 8) return 'كلمة السر يجب أن لا تقل عن 8 أحرف';
    return null;
  }

  static String? validateNewPasswordConfirmation(String? value, String newPassword) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'أعد إدخال كلمة السر الجديدة';
    if (v != newPassword.trim()) return 'كلمتا السر غير متطابقتين';
    return null;
  }
  
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل اسمك بالكامل';
    }
    return null;
  }

  static String? validateCourseTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'عنوان الكورس مطلوب';
    }
    if (value.trim().length < 5) {
      return 'عنوان الكورس يجب أن يكون أكثر من 5 أحرف';
    }
    return null;
  }

  static String? validateCourseDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'وصف الكورس مطلوب';
    }
    if (value.trim().length < 10) {
      return 'وصف الكورس يجب أن يكون أكثر من 10 أحرف';
    }
    return null;
  }

  static String? validateCoursePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'سعر الكورس مطلوب';
    }
    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'يرجى إدخال سعر صحيح';
    }
    if (price < 0) {
      return 'السعر لا يمكن أن يكون أقل من صفر';
    }
    
    return null;
  }

  
  static String? validateLessonTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'عنوان الدرس مطلوب';
    }
    return null;
  }

  static String? validateUrl(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || (!uri.hasScheme || (!uri.scheme.startsWith('http')))) {
      return 'يرجى إدخال رابط صحيح';
    }
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    if (value.trim().length < minLength) {
      return '$fieldName يجب أن يكون أكثر من $minLength أحرف';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    if (value.trim().length > maxLength) {
      return '$fieldName يجب أن يكون أقل من $maxLength أحرف';
    }
    return null;
  }

  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    
    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'يرجى إدخال رقم صحيح';
    }
    
    return null;
  }

  static String? validateGoogleDrivePdfUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رابط PDF مطلوب';
    }    
    final trimmedValue = value.trim();
    final uri = Uri.tryParse(trimmedValue);
    if (uri == null || (!uri.hasScheme || (!uri.scheme.startsWith('http')))) {
      return 'يرجى إدخال رابط صحيح';
    }    
    if (!trimmedValue.contains('drive.google.com')) {
      return 'يرجى إدخال رابط Google Drive صحيح';
    }    
    if (!trimmedValue.contains('/file/d/') && !trimmedValue.contains('id=')) {
      return 'يرجى إدخال رابط Google Drive صحيح يحتوي على معرف الملف';
    }
    return null;
  }

  static String? validatePdfUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رابط PDF مطلوب';
    }    
    final trimmedValue = value.trim();
    if (trimmedValue.startsWith('assets/')) {
      return null;
    }
    final uri = Uri.tryParse(trimmedValue);
    if (uri == null || (!uri.hasScheme || (!uri.scheme.startsWith('http')))) {
      return 'يرجى إدخال رابط صحيح';
    }    
    if (!trimmedValue.toLowerCase().endsWith('.pdf') && 
        !trimmedValue.contains('drive.google.com') &&
        !trimmedValue.contains('pdf')) {
      return 'يرجى إدخال رابط ملف PDF صحيح';
    }
    return null;
  }
}