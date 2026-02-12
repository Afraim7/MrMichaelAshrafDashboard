class AppStrings {
  AppStrings._();

  static final errors = _Errors();
  static final emptyStates = _EmptyStates();
  static final success = _Success();
  static final general = _General();
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
  final String updatesSaved = 'تم حفظ التحديثات بنجاح';
  final String examDeleted = 'تم حذف الامتحان بنجاح';
  final String coursePublished = 'تم نشر الكورس بنجاح';
  final String courseDeleted = 'تم حذف الكورس بنجاح';
  final String highlightPublished =
      'ٌتم النشر بنجاح يمكن للطلبة الان الأطلاع علي ما نشرته من خلال التطبيق';
  final String highlightDeleted = 'تم حذف الملاحظة بنجاح';
  final String commentDeleted = 'تم حذف التعليق بنجاح';
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
}
