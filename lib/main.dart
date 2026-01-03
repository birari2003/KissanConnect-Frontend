import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_translate/flutter_translate.dart';
import "package:flutter_localizations/flutter_localizations.dart";
import 'app/routes/app_pages.dart';
import 'app/utils/api.dart';

import 'app/widhets/global_chatbot_widget.dart';
import 'app/controllers/global_chatbot_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  ApiConfig.initialize('local'); // Change this to 'local' or 'production'

  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en',
    supportedLocales: ['en', 'hi', 'mr'],
    basePath: 'assets/i18n',
  );

  runApp(LocalizedApp(delegate, MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: GetMaterialApp(
        title: "Smart Shetkari",
        debugShowCheckedModeBanner: false,
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,

        routingCallback: (routing) {
          if (routing != null && Get.isRegistered<GlobalChatbotController>()) {
            Get.find<GlobalChatbotController>().checkVisibility(
              routing.current,
            );
          }
        },

        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          localizationDelegate,
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        builder: (context, child) {
          return GlobalChatbotWidget(child: child!);
        },
      ),
    );
  }
}
