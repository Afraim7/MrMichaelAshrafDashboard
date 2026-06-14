import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Mirror of the student app's `ArchiveRepoImp.hashUserId` (sha256 of the raw
/// uid utf8-encoded). Kept identical bit-for-bit so admin-archived records
/// (e.g. from an unenroll) land under the SAME `archive/{hashedUid}` doc the
/// student app uses when a user deletes their own account.
///
/// If the student app ever changes its hash, this function MUST move in
/// lock-step — otherwise archives from the dashboard would be invisible to
/// the rest of the system.
class ArchiveKeys {
  ArchiveKeys._();

  static String hashUserId(String uid) {
    final bytes = utf8.encode(uid);
    return sha256.convert(bytes).toString();
  }
}
