import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dialogflow_grpc/dialogflow_grpc.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../widgets/top_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _messages = [];
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
      print("Error al inicializar SpeechToText: $e");
    }
  }

  void startListening() async {
    if (available ?? false) {
      setState(() => _isListening = true); // Habilita el botón de micrófono
      try {
        _speech?.listen(
            onResult: (val) => setState(() {
                  _textController.text = val.recognizedWords;
                  _isListening =
                      false; // Desactiva el botón de micrófono después de recibir el resultado
                }));
      } catch (e) {
        print("Error al empezar a escuchar: $e");
        setState(() => _isListening = false);
      }
    } else {
      print("El reconocimiento de voz no está disponible.");
      setState(() => _isListening = false);
    }
  }

  void initTts() {
    flutterTts = FlutterTts();

    flutterTts?.setLanguage("es-ES");

    flutterTts?.setStartHandler(() {
      print("Reproducción de voz iniciada");
    });

    flutterTts?.setCompletionHandler(() {
      print("Reproducción de voz completada");
    });

    flutterTts?.setErrorHandler((msg) {
      print("Error en la reproducción de voz: $msg");
    });
  }

  Future<void> initDialogflow() async {
    final serviceAccount = ServiceAccount.fromString(
      await rootBundle.loadString('assets/dialogflowetsiit-3520cf6a0872.json'),
    );
    dialogflow = DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);
  }

  void _handleSubmitted(String text) async {
    print("Mensaje enviado: $text");
    _textController.clear();
    setState(() {
      _messages.insert(0, {'text': text, 'isUserMessage': true});
    });

    // Enviar el mensaje a Dialogflow
    DetectIntentResponse response = await dialogflow!.detectIntent(text, 'es');
    String fulfillmentText = response.queryResult.fulfillmentText;

    // Agregar la respuesta de Dialogflow a la lista de mensajes
    setState(() {
      _messages.insert(0, {'text': fulfillmentText, 'isUserMessage': false});
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
      appBar: const TopBar(
        title: "Asistente Chat",
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, index) => ListTile(
                title: Text(
                  _messages[index]['text'],
                  style: TextStyle(
                    color: _messages[index]['isUserMessage']
                        ? Colors.black
                        : Colors.orange, // Respuestas de Dialogflow en naranja
                  ),
                ),
              ),
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
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                    const InputDecoration.collapsed(hintText: "Enviar mensaje"),
              ),
            ),
            IconButton(
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
              onPressed: _isListening ? () => _speech?.stop() : startListening,
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
