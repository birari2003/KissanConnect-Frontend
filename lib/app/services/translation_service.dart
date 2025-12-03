import 'package:translator/translator.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  /// Translates the given [text] to the [targetLanguage].
  /// If [targetLanguage] is 'en' (English), returns the original text.
  /// Returns the original text if translation fails or text is empty.
  Future<String> translateText(String text, String targetLanguage) async {
    if (text.isEmpty) return text;

    // Assuming the source content is in English.
    // If the target is also English, no need to translate.
    if (targetLanguage == 'en' || targetLanguage == 'en_US') {
      return text;
    }

    try {
      // Extract language code if it has region (e.g., 'en_US' -> 'en')
      // GoogleTranslator usually expects 'en', 'hi', 'mr'.
      String langCode = targetLanguage;
      if (targetLanguage.contains('_')) {
        langCode = targetLanguage.split('_')[0];
      } else if (targetLanguage.contains('-')) {
        langCode = targetLanguage.split('-')[0];
      }

      print('DEBUG: TranslationService translating "$text" to "$langCode"');
      var translation = await _translator
          .translate(text, from: 'en', to: langCode)
          .timeout(const Duration(seconds: 5));
      print('DEBUG: Translation Result: "${translation.text}"');
      return translation.text;
    } catch (e) {
      print('Translation Error: $e');
      return text;
    }
  }
}
