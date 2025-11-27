enum MediaType {
  video,
  pdf,
  test,
}

extension MediaTypeX on MediaType {
  static List<MediaType> getAllMediaTypes() => MediaType.values;
}


