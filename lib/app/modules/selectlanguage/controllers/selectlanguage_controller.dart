import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'dart:ui';

class Language {
  final String name;
  final String code;
  final String greeting;

  Language({required this.name, required this.code, required this.greeting});
}

class SelectlanguageController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();
  final Rx<Language?> selectedLanguage = Rx<Language?>(null);
  final RxBool isSpeaking = false.obs;

  final List<Language> languages = [
    Language(
      name: 'English',
      code: 'en',
      greeting: 'You have selected English, thank you',
    ),
    Language(
      name: 'हिंदी',
      code: 'hi',
      greeting: 'आपने हिंदी चुनी है, धन्यवाद',
    ),
    Language(
      name: 'मराठी',
      code: 'mr',
      greeting: 'तुम्ही मराठी निवडली आहे, धन्यवाद',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      // Set up TTS
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.setLanguage('en-US');
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);

      // Set completion handler
      flutterTts.setCompletionHandler(() {
        isSpeaking.value = false;
        // Navigate to home after speech is done
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed(
            '/loginsignup',
            arguments: {'language': selectedLanguage.value?.code ?? 'en'},
          );
        });
      });

      // Set error handler
      flutterTts.setErrorHandler((msg) {
        isSpeaking.value = false;
        print('TTS Error: $msg');
        // Still navigate even if TTS fails
        Get.offAllNamed(
          '/loginsignup',
          arguments: {'language': selectedLanguage.value?.code ?? 'en'},
        );
      });
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  Future<void> selectLanguage(Language language) async {
    try {
      selectedLanguage.value = language;

      // Change app locale
      await changeLocale(Get.context!, language.code);
      Get.updateLocale(Locale(language.code));

      await flutterTts.setLanguage(
        language.code == 'en' ? 'en-US' : '${language.code}-IN',
      );
      isSpeaking.value = true;

      // Stop any ongoing speech before starting new one
      await flutterTts.stop();

      // Speak the greeting
      await flutterTts.speak(language.greeting);
    } catch (e) {
      print('Error in selectLanguage: $e');
      isSpeaking.value = false;
      // Still navigate even if TTS fails
      Get.offAllNamed('/loginsignup', arguments: {'language': language.code});
    }
  }

  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }
}
