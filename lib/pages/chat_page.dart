import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dialogflow_grpc/dialogflow_grpc.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../widgets/top_bar.dart';
import '../widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  DialogflowGrpcV2Beta1? dialogflow;
  FlutterTts? flutterTts;
  stt.SpeechToText? _speech;
  bool _isListening = false;
  bool? available;

  @override
  void initState() {
    super.initState();
    initDialogflow();
    initTts();
    _initSpeechToText();
  }

  Future<void> _initSpeechToText() async {
    _speech = stt.SpeechToText();
    try {
      available = await _speech?.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      setState(() {
        _isListening = available ?? false;
      });
    } catch (e) {
      print("Error initializing SpeechToText: $e");
    }
  }

  void startListening() async {
    if (available ?? false) {
      setState(() => _isListening = true);
      try {
        _speech?.listen(
            onResult: (val) => setState(() {
                  _textController.text = val.recognizedWords;
                  _isListening = false;
                }));
      } catch (e) {
        print("Error starting listening: $e");
        setState(() => _isListening = false);
      }
    } else {
      print("Speech recognition not available.");
      setState(() => _isListening = false);
    }
  }

  void initTts() {
    flutterTts = FlutterTts();

    flutterTts?.setLanguage("es-ES");

    flutterTts?.setStartHandler(() {
      print("Voice playback started");
    });

    flutterTts?.setCompletionHandler(() {
      print("Voice playback completed");
    });

    flutterTts?.setErrorHandler((msg) {
      print("Error in voice playback: $msg");
    });
  }

  Future<void> initDialogflow() async {
    final serviceAccount = ServiceAccount.fromString(
      await rootBundle.loadString('assets/dialogflowetsiit-3520cf6a0872.json'),
    );
    dialogflow = DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);
  }

  void _handleSubmitted(String text) async {
    print("Message sent: $text");
    _textController.clear();

    ChatMessage userMessage = ChatMessage(
      text: text,
      name: "Luis",
      type: true,
    );

    setState(() {
      _messages.insert(0, userMessage);
    });

    DetectIntentResponse response = await dialogflow!.detectIntent(text, 'es');
    String fulfillmentText = response.queryResult.fulfillmentText;

    ChatMessage botMessage = ChatMessage(
      text: fulfillmentText,
      name: "Bot",
      type: false,
    );

    setState(() {
      _messages.insert(0, botMessage);
    });

    await flutterTts?.speak(fulfillmentText);
  }

  @override
  void dispose() {
    flutterTts?.stop();
    _speech?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title: "Tu asistente personal de la ETSIIT",
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, index) => _messages[index],
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.orangeAccent),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: "Envía un mensaje",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
