import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:llm_jam/blocs/auth/auth_bloc.dart';
import 'package:llm_jam/screens/chat_screen.dart';
import 'package:llm_jam/screens/login_screen.dart';
import 'package:llm_jam/blocs/home/home_bloc.dart';
import 'package:llm_jam/repository/chat_repository.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final chatRepo = ChatRepository();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
              case HomeError:
                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'Welcome, ${user['firstName']} ${user['lastName']}!\n\nStart with a New Chat 👇',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    BottomAppBar(  
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(60, 60),
                              padding: EdgeInsets.all(0),
                              iconSize: 40,
                              iconColor: Colors.white,
                              shape: CircleBorder(),
                              backgroundColor: Colors.black,
                            ),
                            onPressed: (){
                              context.read<HomeBloc>().add(NewChatSession());
                            }, 
                            child: Icon(Icons.add)
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              case HomeLoaded:
                final sessions = (state as HomeLoaded).chatSessions;
                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: sessions.length,
                        padding: const EdgeInsets.all(10),
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          return ListTile(
                            title: Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                            ),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    id: session.id, 
                                    title: session.title, 
                                    description: session.description, 
                                    chat: session.chat
                                    )
                                  ),
                              );                         
                            },
                            subtitle: Text(
                              '\n${session.description}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis
                            ),
                            textColor: Colors.white,
                            titleTextStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            subtitleTextStyle: TextStyle(
                              color: Colors.white70,                      
                              fontSize: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.all(15),
                            tileColor: const Color.fromARGB(255, 33, 1, 54),
                          );
                        },
                        separatorBuilder: (context, index) => SizedBox(height: 16),
                      ),
                    ),
                    BottomAppBar(  
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(60, 60),
                              padding: EdgeInsets.all(0),
                              iconSize: 40,
                              iconColor: Colors.white,
                              shape: CircleBorder(),
                              backgroundColor: Colors.black,
                            ),
                            onPressed: (){
                              context.read<HomeBloc>().add(NewChatSession());
                            }, 
                            child: Icon(Icons.add)
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              case HomeNewSession:
                return Scaffold(
                  body: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        TextField(
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: "Enter Chat Title"
                            ),
                        ),
                        SizedBox(height: 100),
                        TextField(
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            hintText: "Enter Chat Description",
                            ),
                        ),
                      ]
                    )
                  ),
                  bottomNavigationBar: BottomAppBar(
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(400, 50),
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 20),                            
                          ),
                          onPressed: (){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  id: '', 
                                  title: _titleController.text, 
                                  description: _descriptionController.text, 
                                  chat: []
                                )
                              ),
                            );
                          }, child: const Text('Create Chat Session')
                        ),
                      ),
                    ),
                  ),
                );
              default:
              return Center(
                child: Text(
                  'Welcome, ${user['firstName']} ${user['lastName']}!\nBruhh, smtg got f*d up.',
                  style: const TextStyle(fontSize: 20),
                ),
              );
            }
          },
        ),
      ), 
    );
  }
}
