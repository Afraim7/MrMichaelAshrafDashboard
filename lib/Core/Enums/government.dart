enum Government {
  cairo,
  giza,
  qalyubia,
  alexandria,
  dakahlia,
  gharbia,
  sharqia,
  monufia,
  ismailia,
  suez,
  portSaid,
  beniSuef,
  fayoum,
  minya,
  asyut,
  sohag,
  qena,
  luxor,
  aswan,
  redSea,
  northSinai,
  southSinai,
  behaira,
  kafrElSheikh,
  matrouh,
  newValley,
}

extension GovernmentX on Government {
  static List<Government> getAllGovernments() => Government.values;
  String get label {
    switch (this) {
      case Government.cairo: return 'القاهرة';
      case Government.giza: return 'الجيزة';
      case Government.qalyubia: return 'القليوبية';
      case Government.alexandria: return 'الإسكندرية';
      case Government.dakahlia: return 'الدقهلية';
      case Government.gharbia: return 'الغربية';
      case Government.sharqia: return 'الشرقية';
      case Government.monufia: return 'المنوفية';
      case Government.ismailia: return 'الإسماعيلية';
      case Government.suez: return 'السويس';
      case Government.portSaid: return 'بورسعيد';
      case Government.beniSuef: return 'بني سويف';
      case Government.fayoum: return 'الفيوم';
      case Government.minya: return 'المنيا';
      case Government.asyut: return 'أسيوط';
      case Government.sohag: return 'سوهاج';
      case Government.qena: return 'قنا';
      case Government.luxor: return 'الأقصر';
      case Government.aswan: return 'أسوان';
      case Government.redSea: return 'البحر الأحمر';
      case Government.northSinai: return 'شمال سيناء';
      case Government.southSinai: return 'جنوب سيناء';
      case Government.behaira: return 'البحيرة';
      case Government.kafrElSheikh: return 'كفر الشيخ';
      case Government.matrouh: return 'مطروح';
      case Government.newValley: return 'الوادي الجديد';
    }
  }

  static Government? fromLabel(String label) {
    for (final g in Government.values) {
      if (g.label == label) return g;
    }
    return null;
  }
}


