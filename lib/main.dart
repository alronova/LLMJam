import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:llm_jam/repository/auth_repository.dart';
import 'package:llm_jam/screens/home_screen.dart';
import 'package:llm_jam/screens/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();
  // await storage.deleteAll();
  final value = await storage.read(key: 'auth_user');
  final token = await storage.read(key: 'auth_token');
  debugPrint('Stored value: $value\n token: $token');
  await dotenv.load(fileName: ".env");
  runApp(LLMJam());
}

class LLMJam extends StatelessWidget {
  LLMJam({super.key});
  final AuthRepository authRepo = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LLM JAM',
      home: FutureBuilder(
        future: authRepo.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            if (snapshot.hasData) {
              final user = snapshot.data!;
              return HomeScreen(user: user); // Pass user to HomeScreen
            } else {
              return LoginScreen();
            }
          }
        },
      ),
    );
  }
}