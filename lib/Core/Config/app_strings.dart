class AppStrings {
  AppStrings._();

  static final appName = _AppName();
  static final errors = _Errors();
  static final emptyStates = _EmptyStates();
  static final success = _Success();
  static final general = _General();
}

class _AppName {
  const _AppName();
  final String name = "مستر مايكل أشرف";
}

class _Errors {
  const _Errors();
  final String examLoadFailed = 'فشل تحميل قائمة الامتحانات';
  final String examAnswersLoadFailed = 'فشل تحميل الإجابات';
  final String examAnswersNotAvailable = 'لا توجد إجابات متاحة لهذا الامتحان';
  final String examPublishFailed = 'فشل في نشر الامتحان';
  final String examUpdateFailed = 'فشل في حفظ التحديثات';
  final String examDeleteFailed = 'فشل في حذف الامتحان';
  final String examLoadFailedAdmin = 'فشل في تحميل الامتحانات';
  final String courseLoadFailed = 'فشل في جلب الكورسات';
  final String courseEnrolledLoadFailed = 'فشل في جلب الكورسات المسجلة';
  final String courseEnrollFailed = 'فشل في التسجيل في الكورس';
  final String courseUnenrollFailed = 'فشل في إلغاء التسجيل';
  final String courseProgressUpdateFailed = 'فشل في تحديث تقدم الدرس';
  final String courseCommentsLoadFailed = 'فشل في جلب التعليقات';
  final String courseCommentAddFailed = 'فشل في إضافة التعليق';
  final String courseCommentDeleteFailed = 'فشل في حذف التعليق';
  final String coursePublishFailed = 'فشل في نشر الكورس';
  final String courseDeleteFailed = 'فشل في حذف الكورس';
  final String courseUpdateFailed = 'فشل في حفظ التحديثات';
  final String courseImageSelectFailed = 'فشل في اختيار الصورة';
  final String highlightPublishFailed = 'فشل في نشر التمييز';
  final String highlightLoadFailed =
      'حصل خطأ أثناء تحميل الملاحظات، حاول مرة أخري';
  final String highlightDeleteFailed = 'فشل في حذف الملاحظة حاول مرة أخري';
  final String notesLoadFailed =
      'فشل في تحميل الملاحظات يرجي التحقق من أتصالك والمحاولة مرة أخري';
  final String imageNotSelected = 'لم يتم اختيار صورة';
  final String notificationLoadFailed = 'فشل في جلب الإشعارات';
  final String notificationUpdateFailed = 'فشل في تحديث حالة الإشعار';
  final String notificationUpdateAllFailed = 'فشل في تحديث جميع الإشعارات';
  final String notificationDeleteFailed = 'فشل في حذف الإشعار';
  final String loginRequired = 'يجب تسجيل الدخول لعرض الإجابات';
  final String userNotLoggedIn = 'المستخدم غير مسجل الدخول';
  final String commentNotFound = 'التعليق غير موجود';
  final String commentDeletePermissionDenied =
      'ليس لديك صلاحية لحذف هذا التعليق';
  final String defaultError =
      'حدث خطأ غير متوقع, يرجي التحقق من اتصالك والمحاولة مرة أخري.';
  final String pdfLoadFailed = 'فشل تحميل ملف PDF';
  final String emailVerificationFailed = 'فشل التحقق من البريد الإلكتروني';
  final String passwordMustBeDifferent =
      'يجب أن تختلف كلمة السر الجديدة عن المستخدمة حاليا أو كلمات المرور السابقة.';
  final String userDataLoadFailed =
      'تعذّر تحميل بيانات المستخدم يرجي المحاولة لاحقا.';
  final String unexpectedError = 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.';
  final String loginFailed = 'تعذّر تسجيل الدخول. يرجي المحاولة مرة أخرى.';
  final String userDataLoadFailedRetry =
      'تعذّر تحميل بياناتك تأكد من اتصالك وحاول مرة أخري.';
  final String accountCreationFailed =
      'تعذّر إنشاء الحساب تأكد من بياناتك واتصالك بالأنترنت وحاول مرة أخرى.';
  final String verificationEmailSendFailed =
      'تعذّر إرسال رسالة التفعيل. يرجى المحاولة مرة أخرى.';
  final String userDataLoadFailedLater =
      'تعذّر تحميل بيانات المستخدم. يرجي المحاولة لاحقًا.';
  final String requiredFieldsNotFilled = 'يرجى ملء جميع الحقول المطلوبة';
  final String linkOpenFailed =
      'حدث خطأ أثناء محاولة فتح الرابط حاول مرة أخرى لاحقاً';
  final String phoneCallFailed =
      'حدث خطأ أثناء محاولة إجراء المكالمة حاول مرة أخرى لاحقاً';
  final String studentsLoadFailed = 'فشل في تحميل الطلاب';
  final String alreadyEnrolled = 'أنت مسجل بالفعل في هذا الكورس';
  final String enrollmentNotFound = 'لم يتم العثور على تسجيل في هذا الكورس';
}

class _EmptyStates {
  const _EmptyStates();
  final String noExams = 'لا توجد امتحانات حالياً';
  final String noExamsForGrade = 'لا توجد امتحانات للصف المحدد';
  final String noQuestionsInExam = 'لا توجد أسئلة في هذا الامتحان';
  final String noCourses =
      'لا يوجد كورسات هنا حاليا \n سيتم توفيرها في أقرب وقت بإذن الله.';
  final String noCoursesForGrade = 'لا توجد كورسات للصف المحدد';
  final String noPublishedCourses = 'لم تقم بنشر أي كورسات حتي الأن';
  final String noPublishedExams = 'لم تقم بنشر أي امتحانات حتي الأن';
  final String noEnrolledCourses = 'ليس لديك أي دورات مسجلة حاليا.';
  final String noComments = 'لا توجد تعليقات بعد،\n كن أول من يشارك رأيه!';
  final String noCommentsOnCourse =
      'لا توجد تعليقات أو أراء بعد علي هذا الكورس';
  final String subscribeToViewContent =
      'يرجي الأشتراك في الكورس لعرض كل دروس ومحتوي الكورس';
  final String noNotifications = 'لا يوجد لديك اي إشعارات';
  final String noHighlights = 'لم تقم بنشر أي ملاحظات حتي الأن';
  final String noHighlightsForGrade = 'لا توجد ملاحظات للصف المحدد';
  final String noDate = 'لا يوجد تاريخ';
  final String noStudents = 'لا يوجد طلاب مسجلين حالياً';
  final String noStudentsForGrade = 'لا يوجد طلاب للصف المحدد';
}

class _Success {
  const _Success();
  final String examPublished = 'تم نشر الامتحان بنجاح';
  final String examUpdated = 'تم حفظ التحديثات بنجاح';
  final String examDeleted = 'تم حذف الامتحان بنجاح';
  final String coursePublished = 'تم نشر الكورس بنجاح';
  final String courseUpdated = 'تم حفظ التحديثات بنجاح';
  final String courseDeleted = 'تم حذف الكورس بنجاح';
  final String highlightPublished =
      'ٌتم النشر بنجاح يمكن للطلبة الان الأطلاع علي ما نشرته من خلال التطبيق';
  final String highlightDeleted = 'تم حذف الملاحظة بنجاح';
  final String courseEnrolled = 'تم الاشتراك بنجاح 🎉';
  final String passwordChanged = 'تم تغيير كلمة المرور بنجاح ✅';
  final String commentAdded = 'تم إضافة التعليق بنجاح';
  final String commentDeleted = 'تم حذف التعليق بنجاح';
  final String unenrollSuccess = 'تم إلغاء الاشتراك بنجاح';
}

class _General {
  _General();
  final String retry = 'قم بأعادة المحاولة';
  final String noResultAvailable = 'لا توجد نتيجة متاحة لهذا الامتحان.';
  final String emptyComment = 'لم تقم بكتابة اي شئ';
  final String loginSuccess = 'تم تسجيل الدخول بنجاح';
  final String adminLoginSuccess = 'تم تسجيل الدخول بنجاح مرحبا بك مرة أخري';
  final List<String> weekdaysAr = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];
  final List<String> monthsAr = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  String generateAuthErrorMessage({required String errorCode}) {
    final code = errorCode.trim().toLowerCase();
    switch (code) {
      case 'invalid-email':
        return 'هذا الأيميل غير صالح نأكد من كنابتة بشكل صحيح';
      case 'user-disabled':
        return 'للاسف تم ايقاف هذا الحساب';
      case 'user-not-found':
        return 'لا يوجد مستخدم مسجَّل بهذا الأيميل.';
      case 'wrong-password':
      case 'invalid-password':
        return 'كلمة السر غير صحيحة. يرجى المحاولة مرة أخرى.';
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة السر غير صحيحة.';
      case 'operation-not-allowed':
        return 'طريقة تسجيل الدخول هذه غير مفعّلة لدى التطبيق جرب تسجيل الدخول بالأيميل وكلمة السر.';
      case 'too-many-requests':
        return '';
      case 'network-request-failed':
        return 'يوجد مشكلة في الأتصال بالأنترنت يرجي التأكد من أتصالك والمحاولة مرة أخري';
      case 'internal-error':
        return 'خطأ داخلي غير متوقع. يرجي المحاولة لاحقًا.';
      case 'timeout':
        return 'انتهت مهلة العملية. تحقّق من الشبكة ثم حاول مجددًا.';
      case 'unknown':
        return 'حدث خطأ غير متوقع. حاول مرة أخرى لاحقًا.';
      case 'email-already-in-use':
        return 'هذا الأيميل مستخدم بالفعل. جرّب تسجيل الدخول أو استخدم ايميلا آخر.';
      case 'weak-password':
        return 'كلمة السر ضعيفة. اختر كلمة أقوى يجب أن تتضمن حروف وأرقام ورموز وان لا تقل عن 8 أحرف.';
      case 'missing-password':
        return 'من فضلك قم بأدخال كلمة السر.';
      case 'missing-email':
        return 'من فضلك قم بأدخال الايميل لإرسال رابط إعادة تعيين كلمة السر.';
      case 'invalid-login-credentials':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة، أو انتهت صلاحية بيانات الاعتماد.';
      case 'user-mismatch':
        return 'بيانات الاعتماد لا تتطابق مع المستخدم الحالي.';
      case 'user-token-expired':
        return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول من جديد.';
      case 'app-not-authorized':
        return 'التطبيق غير مخوَّل لاستخدام Firebase Auth.';
      case 'invalid-api-key':
        return 'مفتاح API غير صالح لتطبيق Firebase.';
      case 'quota-exceeded':
        return 'تم تجاوز الحد المسموح. حاول لاحقًا.';
      case 'code-expired':
        return 'انتهت صلاحية رمز التحقق. أعد المحاولة مرة أخري.';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح. تأكّد من الرمز وحاول مرة أخري.';
      case 'invalid-verification-id':
        return 'معرّف التحقق غير صالح.';
      case 'captcha-check-failed':
        return 'فشل التحقق الآلي (CAPTCHA). أعد المحاولة.';
      case 'account-exists-with-different-credential':
        return 'هناك حساب بنفس البريد ولكن بطريقة تسجيل مختلفة. جرّب "نسيت كلمة المرور".';
      case 'invalid-continue-uri':
        return 'رابط المتابعة غير صالح. راجع الإعدادات.';
      case 'missing-continue-uri':
        return 'رابط المتابعة مفقود. راجع الإعدادات.';
      case 'missing-android-pkg-name':
        return 'اسم حزمة أندرويد مفقود لهذا الإعداد. راجع الإعدادات.';
      case 'missing-ios-bundle-id':
        return 'معرّف حزمة iOS مفقود لهذا الإعداد. راجع الإعدادات.';
      case 'unauthorized-continue-uri':
        return 'رابط المتابعة غير مخوّل. تأكد من إعدادات قائمة النطاقات المسموح بها.';
      case 'requires-recent-login':
        return 'للأمان، سجّل الدخول من جديد ثم أعد المحاولة.';
      default:
        return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
    }
  }
}
