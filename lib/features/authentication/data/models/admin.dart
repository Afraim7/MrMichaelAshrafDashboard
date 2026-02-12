import 'package:mrmichaelashrafdashboard/core/config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/enums/gender.dart';

class Admin {
  final String adminID;
  final String adminName;
  final String email;
  final Gender gender;
  final String phone;
  final bool emailVerified;
  final String? photoURL;

  Admin({
    required this.adminID,
    required this.adminName,
    required this.email,
    required this.gender,
    required this.phone,
    this.emailVerified = false,
    String? photoURL,
  }) : photoURL = photoURL ?? _defaultProfilePic(gender);

  static String _defaultProfilePic(Gender g) {
    return g == Gender.male
        ? AppAssets.images.adminMale
        : (g == Gender.female)
        ? AppAssets.images.adminFemale
        : AppAssets.images.defaultAvatar;
  }

  Admin copyWith({
    String? adminID,
    String? adminName,
    String? email,
    Gender? gender,
    String? phone,
    bool? emailVerified,
    String? photoURL,
  }) {
    return Admin(
      adminID: adminID ?? this.adminID,
      adminName: adminName ?? this.adminName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      emailVerified: emailVerified ?? this.emailVerified,
      photoURL: photoURL ?? this.photoURL,
    );
  }

  // TO MAP
  Map<String, dynamic> toMap() {
    return {
      'adminID': adminID,
      'adminName': adminName,
      'email': email,
      'gender': gender.name,
      'phone': phone,
      'emailVerified': emailVerified,
      'photoURL': photoURL,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    Gender parseGender(String? v) {
      return Gender.values.firstWhere(
        (g) => g.name == v,
        orElse: () => Gender.male,
      );
    }

    return Admin(
      adminID: map['adminID'] ?? '',
      adminName: map['adminName'] ?? 'Unknown Admin',
      email: map['email'] ?? '',
      gender: parseGender(map['gender']),
      phone: map['phone'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
      photoURL: map['photoURL'],
    );
  }
}
