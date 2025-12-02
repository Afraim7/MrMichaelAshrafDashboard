class AppAssets {
  AppAssets._();

  static const animations = _Animations();
  static const images = _Images();
  static const pdfs = _Pdfs();
}

class _Animations {
  const _Animations();
  final String celebration = 'assets/animations/Celebration.json';
  final String coursesTap = 'assets/animations/Courses Tap.json';
  final String emptyCoursesList = 'assets/animations/Empty Courses List.json';
  final String emptyNotificationList =
      'assets/animations/Empty Notification List.json';
  final String homeTap = 'assets/animations/Home Tap.json';
  final String menuTap = 'assets/animations/Menu.json';
  final String examsTap = 'assets/animations/examsTap.json';
  final String emptyExamsList = 'assets/animations/empty exams list.json';
  final String emptyHighlightList =
      'assets/animations/Empty Highlight List.json';
  final String emptyStudentsList =
      'assets/animations/Empty Students List.json';
  final String noConnection = 'assets/animations/No Internet Connection.json';
  final String noEnrolledCourses = 'assets/animations/No Enrolled Courses.json';
  final String notificationTap = 'assets/animations/Notification Tap.json';
  final String openBook = 'assets/animations/Open book.json';
  final String profileTap = 'assets/animations/Profile Tap.json';
  final String visionTap = 'assets/animations/Vision Tap.json';
  final String happyStudentsStudying =
      'assets/animations/Happy Students Studying..json';
  final String success = 'assets/animations/Success.json';
  final String emailSent = 'assets/animations/Emailsent.json';
  final String redWarning = 'assets/animations/redWarning.json';
  final String yellowWarning = 'assets/animations/yellowWarning.json';
  final String verifiedSuccess = 'assets/animations/verification Badge.json';
  final String addToCartSuccess = 'assets/animations/Add To Cart Success.json';
  final String cart = 'assets/animations/shopping cart.json';
  final String checkedSuccess = 'assets/animations/checked.json';
}

class _Images {
  const _Images();
  final String courseDefault = 'assets/images/course_placeholder.jpeg';
  final String maleStudent = 'assets/images/malestudent.png';
  final String femaleStudent = 'assets/images/femalestudent.png';
  final String adminMale = 'assets/images/teacher_admin.png';
  final String adminFemale = 'assets/images/teacher_admin_female.png';
  final String defaultAvatar = 'assets/images/defaultavatar.jpg';
}

class _Pdfs {
  const _Pdfs();
  final String lessonPlaceholder = 'assets/pdfs/lessonPdfPlacehokder.pdf';
}
