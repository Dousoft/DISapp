import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isd/Controllers/login_controller.dart';
import 'package:isd/Controllers/sound_controller.dart';
import 'package:isd/Utils/colors.dart';
import 'package:isd/Views/LoginView/login_page.dart';
import 'package:provider/provider.dart';

import 'Views/HomeView/home_page.dart';
import 'web/web_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAYFeiAhipla4eRRaQqmBTMub-e6NZF_rI",
        authDomain: "isd-india.firebaseapp.com",
        projectId: "isd-india",
        storageBucket: "isd-india.appspot.com",
        messagingSenderId: "1031280782935",
        appId: "1:1031280782935:web:facc33bcf51b021cc03d12",
        measurementId: "G-L7D66WDJRQ",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => SoundController()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ISD',
        theme: ThemeData(
          scaffoldBackgroundColor: backColor,
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
          ),
          fontFamily: kIsWeb
              ? GoogleFonts.lato().fontFamily
              : GoogleFonts.podkova().fontFamily,
        ),
        home: kIsWeb ? const WebPage() : const MainPage(),
        //home: const NewHomePage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const LoginPage();
    } else {
      return const HomePage();
    }
  }
}
