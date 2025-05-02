enum LocalLanguage{
  ar('ar','ar'),
  en('en','en'),

  ;
  const LocalLanguage(this.languageCode,this.countryCode);
  final String languageCode;
  final String countryCode;
  @override
  String toString() => '$languageCode, $countryCode';
}
