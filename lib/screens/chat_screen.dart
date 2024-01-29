import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chatgpt/const.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _openAI = OpenAI.instance.build(
    token: OPENAI_API_KEY,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(
        seconds: 5,
      ),
    ),
    enableLog: true,
  );

  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: 'Muhammad', lastName: 'Suhaib');

  final ChatUser _gptChatUser =
      ChatUser(id: '2', firstName: 'Chat', lastName: 'GPT');
  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(
          0,
          166,
          126,
          1,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        title: const Text(
          'Chat GPT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  0,
                  166,
                  126,
                  1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        'https://media.licdn.com/dms/image/D5603AQEm8gqDfvzrBA/profile-displayphoto-shrink_800_800/0/1689103165548?e=2147483647&v=beta&t=g7TaydPxRthr2NDcvMNIKXHSoi_r2UvYz8FYKz3BuFI',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Developed By Muhammad Suhaib',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Image.network(
                'https://img.icons8.com/color/48/000000/portfolio.png', // Portfolio icon
                height: 24,
                width: 24,
              ),
              title: const Text('Click to See Portfolio'),
              onTap: () {
                // Handle portfolio tap
                launch('https://suhaibportfolio.vercel.app/');
              },
            ),
            ListTile(
              leading: Image.network(
                'https://img.icons8.com/color/48/000000/gmail.png', // Gmail icon
                height: 24,
                width: 24,
              ),
              title: const Text('suhaibusman54@gmail.com'),
              onTap: () {
                launch('mailto:suhaibusman54@gmail.com');
                // Handle email tap
              },
            ),
            ListTile(
              leading: Image.network(
                'https://img.icons8.com/color/48/000000/whatsapp.png', // WhatsApp icon
                height: 24,
                width: 24,
              ),
              title: const Text(' 03112136120'),
              onTap: () {
                launch(
                    'https://api.whatsapp.com/send?phone=+923112136120&text=Hello,%20Suhaib%20See%20Your%20GeminiAiApp');
                // Handle contact tap
              },
            ),
            ListTile(
              leading: Image.network(
                'https://img.icons8.com/color/48/000000/linkedin.png', // LinkedIn icon
                height: 24,
                width: 24,
              ),
              title: const Text('Muhammad Suhaib Usman'),
              onTap: () {
                launch('https://www.linkedin.com/in/suhaibusman/');
              },
            ),
            ListTile(
              leading: Image.network(
                'https://img.icons8.com/color/48/000000/instagram.png', // Instagram icon
                height: 24,
                width: 24,
              ),
              title: const Text('suhaib__usman'),
              onTap: () {
                launch('https://instagram.com/suhaib__usman');
              },
            ),
            ListTile(
              leading: Image.network(
                'https://img.icons8.com/color/48/000000/facebook-new.png', // Facebook icon
                height: 24,
                width: 24,
              ),
              title: const Text('Muhammad Suhaib'),
              onTap: () {
                launch('https://www.facebook.com/MuhammadSuhaib0/');
              },
            ),
          ],
        ),
      ),
      body: DashChat(
          currentUser: _currentUser,
          typingUsers: _typingUsers,
          messageOptions: const MessageOptions(
            currentUserContainerColor: Colors.black,
            containerColor: Color.fromRGBO(
              0,
              166,
              126,
              1,
            ),
            textColor: Colors.white,
          ),
          onSend: (ChatMessage m) {
            getChatResponse(m);
          },
          messages: _messages),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });
    List<Messages> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();
    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: _messagesHistory,
      maxToken: 200,
    );
    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
                user: _gptChatUser,
                createdAt: DateTime.now(),
                text: element.message!.content),
          );
        });
      }
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}
