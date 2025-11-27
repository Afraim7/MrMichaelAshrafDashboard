enum Area {
  // Cairo
  heliopolis,
  nasrCity,
  newCairo,
  maadi,
  shubra,
  hadayekElKobba,
  ainShams,
  elMarg,
  elMatarya,
  elNozha,
  elZaytoun,
  elRehab,
  madinaty,

  // Qalyubia
  elObour,
  khanka,
  mansheyetElGabalElAsfar,
  gabalElAsfar,
  shibinElQanater,

  // Giza
  dokki,
  mohandsen,
  haram,
  october6,
  sheikhZayed,
  tagamoaElKhames,
}

extension AreaX on Area {
  static List<Area> getAllAreas() => Area.values;
  String get label {
    switch (this) {
      case Area.heliopolis: return 'مصر الجديدة';
      case Area.nasrCity: return 'مدينة نصر';
      case Area.newCairo: return 'القاهرة الجديدة';
      case Area.maadi: return 'المعادي';
      case Area.shubra: return 'شبرا';
      case Area.hadayekElKobba: return 'حدائق القبة';
      case Area.ainShams: return 'عين شمس';
      case Area.elMarg: return 'المرج';
      case Area.elMatarya: return 'المطرية';
      case Area.elNozha: return 'النزهة';
      case Area.elZaytoun: return 'الزيتون';
      case Area.elRehab: return 'الرحاب';
      case Area.madinaty: return 'مدينتي';
      case Area.elObour: return 'العبور';
      case Area.khanka: return 'الخانكة';
      case Area.mansheyetElGabalElAsfar: return 'منشية الجبل الأصفر';
      case Area.gabalElAsfar: return 'الجبل الاصفر';
      case Area.shibinElQanater: return 'شبين القناطر';
      case Area.dokki: return 'الدقي';
      case Area.mohandsen: return 'المهندسين';
      case Area.haram: return 'الهرم';
      case Area.october6: return '6 أكتوبر';
      case Area.sheikhZayed: return 'الشيخ زايد';
      case Area.tagamoaElKhames: return 'التجمع الخامس';
    }
  }

  static Area? fromLabel(String label) {
    for (final a in Area.values) {
      if (a.label == label) return a;
    }
    return null;
  }
}


