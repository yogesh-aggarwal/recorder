import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:recorder/core/firebase_options.dart';
import 'package:recorder/providers/user.dart';
import 'package:recorder/widgets/screens/auth/login.dart';
import 'package:recorder/widgets/screens/home/home.dart';
import 'package:recorder/widgets/screens/recordings/recordings.dart';
import 'package:recorder/widgets/screens/settings/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: "Recorder",
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: lightDynamic,
            useMaterial3: true,
            fontFamily: GoogleFonts.inter().fontFamily,
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic,
            useMaterial3: true,
            fontFamily: GoogleFonts.inter().fontFamily,
          ),
          themeMode: ThemeMode.system,
          home: Recorder(),
        );
      },
    );
  }
}

class Recorder extends StatefulWidget {
  const Recorder({super.key});

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    context.read<UserProvider>().initAuth(
          onUserAvailable: () {},
        );

    context.read<UserProvider>().addListener(() {
      if (context.read<UserProvider>().user == null) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    if (user == null) {
      return const Scaffold(
        body: SafeArea(child: LoginScreen()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Recorder",
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
      body: (() {
        switch (_selectedIndex) {
          case 0:
            return const HomeScreen();
          case 1:
            return const RecordingsScreen();
          case 2:
            return const SettingsScreen();
          default:
            return const Placeholder();
        }
      })(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.video_collection),
            icon: Icon(Icons.video_collection_outlined),
            label: 'Gallery',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
