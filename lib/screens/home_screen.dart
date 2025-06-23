import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_jam/blocs/auth/auth_bloc.dart';
import 'package:llm_jam/screens/login_screen.dart';
import 'package:llm_jam/blocs/home/home_bloc.dart';
import 'package:llm_jam/repository/chat_repository.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final chatRepo = ChatRepository();

  HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LLM Jam'),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            color: Colors.white,
            iconSize: 30,
            padding: const EdgeInsets.all(10),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) => HomeBloc(chatRepository: chatRepo)
                                ..add(ChatSessionsRequested()),
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeLoading) {
              Center(child: CircularProgressIndicator());
            } else if (state is HomeLoaded) {
              build(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Status: ${state.message}')),
              );
            } else if (state is HomeError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
            }
          },
          builder: (context, state) {
            switch (state.runtimeType) {
              case HomeLoaded:
                final sessions = (state as HomeLoaded).chatSessions;
                return ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return ListTile(
                      title: Text('Chat ID: ${session.id}'),
                      onTap: () {
                        
                      },
                    );
                  },
                );
              default:
                return const Center(child: Text('Welcome to LLM Jam, bruhh!'));
            }
          },
        ),
      ),
    );
  }
}
