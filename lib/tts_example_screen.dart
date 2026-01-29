
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class SpeechToTextScreen extends StatefulWidget {
//   @override
//   State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
// }

// class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
//   late stt.SpeechToText speech;    // stt voice to text 
//   bool isListening = false;   // mic start and stop 
//   String text = "এখানে আপনার বলা লেখা দেখাবে";  // ui show text 

//   @override
//   void initState() {
//     super.initState();
//     speech = stt.SpeechToText();   // method calling 
//   }

//   Future<void> startListening() async {      // async কারণ microphone permission + initialization async
//     bool available = await speech.initialize(
//       onStatus: (status) {
//         print("STATUS: $status");

//         //   If it turns off by itself, I will turn it back on.
//         if (status == "notListening" && isListening)  {
//           startListening();
//         }
//       },
//       onError: (error) {
//         print("ERROR: $error");
//       },
//     );

//     if (!available) return;

//     setState(() => isListening = true);

//     speech.listen(
//       localeId: "bn_BD",   // language selected
//       // ignore: deprecated_member_use
//       listenMode: stt.ListenMode.dictation,    // continuous
//       // ignore: deprecated_member_use
//       partialResults: true,
//       listenFor: const Duration(minutes: 10), // voice time long session
//       pauseFor: const Duration(seconds: 10),  // silence allowed
//       onResult: (result) {
//         setState(() {
//           text = result.recognizedWords;
//         });
//       },
//     );
//   }

//   void stopListening() {
//     setState(() => isListening = false);
//     speech.stop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Speech to Text (Bangla)")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               text,
//               style: const TextStyle(fontSize: 22),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: isListening ? stopListening : startListening,
//               child: Text(isListening ? "Stop Listening" : "Start Speaking"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class SpeechToTextScreen extends StatefulWidget {
  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  late stt.SpeechToText speech;
  late FlutterTts tts;

  bool isListening = false;
  String text = "";

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    tts = FlutterTts();

    tts.setLanguage("bn-BD");
    tts.setSpeechRate(0.5);
  }

  // 🎤 Voice → Text (CONTINUOUS)
  Future<void> startListening() async {
    bool available = await speech.initialize(
      onStatus: (status) {
        print("STATUS: $status");

        // 🔁 যদি system নিজে থেকে বন্ধ করে দেয়
        if (status == "notListening" && isListening) {
          startListening();
        }
      },
      onError: (error) {
        print("ERROR: $error");
      },
    );

    if (!available) return;

    setState(() => isListening = true);

    speech.listen(
      localeId: "bn_BD",
      listenMode: stt.ListenMode.dictation, //  long speech
      partialResults: true,
      listenFor: const Duration(minutes: 30), // long time
      pauseFor: const Duration(seconds: 15),  //  silence allowed
      onResult: (result) {
        setState(() {
          text = result.recognizedWords;
          controller.text = text;
        });
      },
    );
  }

  void stopListening() {
    setState(() => isListening = false);
    speech.stop();
  }

  // 🔊 Text → Voice
  Future<void> speakText() async {
    if (controller.text.isNotEmpty) {
      await tts.stop(); // আগের voice থাকলে stop
      await tts.speak(controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice ↔ Text (Continuous)")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// TEXT FIELD
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "এখানে লিখুন বা কথা বলুন",
              ),
            ),

            const SizedBox(height: 20),

            /// MIC BUTTON
            ElevatedButton(
              onPressed: isListening ? stopListening : startListening,
              child: Text(isListening ? "Stop Mic" : "Start Mic"),
            ),

            const SizedBox(height: 10),

            /// SPEAK BUTTON
            ElevatedButton(
              onPressed: speakText,
              child: const Text("Read Text"),
            ),
          ],
        ),
      ),
    );
  }
}
