import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:llm_jam/blocs/auth/auth_bloc.dart';
import 'package:llm_jam/repository/auth_repository.dart';
import 'package:llm_jam/screens/home_screen.dart';
import 'package:llm_jam/screens/login_screen.dart';
// import 'package:llm_jam/blocs/home/home_bloc.dart';
import 'package:llm_jam/repository/chat_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(LLMJam());
}

class LLMJam extends StatelessWidget {
  LLMJam({super.key});
  final ChatRepository chatRepo = ChatRepository();
  final AuthRepository authRepo = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AuthBloc(authRepository: authRepo)..add(AuthCheckStatus()),
        ),
        // BlocProvider(
        //   create: (_) => HomeBloc(chatRepository: chatRepo)
        //     ..add(ChatSessionsRequested()),
        // ),
      ],
      child: MaterialApp(
        title: 'LLM JAM',
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (state is Authenticated) {
              return HomeScreen(user: state.user);
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
