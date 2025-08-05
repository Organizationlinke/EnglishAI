// // import 'package:flutter/gestures.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_tts/flutter_tts.dart';
// // import 'package:translator/translator.dart';
// // import '../main.dart';
// // import '../models/story_content_model.dart';
// // import '../widgets/quiz_widgets.dart';
// // import 'dart:async';

// // class ContentScreen extends StatefulWidget {
// //   final int storyId;
// //   final int level;
// //   final int lesson;

// //   const ContentScreen({
// //     super.key,
// //     required this.storyId,
// //     required this.level,
// //     required this.lesson,
// //   });

// //   @override
// //   State<ContentScreen> createState() => _ContentScreenState();
// // }

// // class _ContentScreenState extends State<ContentScreen> {
// //   late Future<StoryContent> _contentFuture;
// //   List<String> rewords = [];
// //   List<String> lessonWords = [];
// //   final FlutterTts tts = FlutterTts();
// //   bool _isCancelled = false;
// //   String? _maleVoice;
// //   String? _femaleVoice;
// //   int? currentSpokenIndex;
// //   bool isSpeakingNormal = false;
// //   bool isSpeakingSlow = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _contentFuture = _fetchContent();
// //     _loadRewords();
// //     _loadLessonWords();
// //     _initTTS();
// //     printAvailableVoices();
// //   }

// //   Future<void> _initTTS() async {
// //     await tts.setLanguage("en-US");
// //     await tts.setPitch(1.0);
// //   }

// //   Future<void> _loadRewords() async {
// //     final response = await supabase
// //         .from('rewords')
// //         .select('word')
// //         .eq('level', widget.level)
// //         .eq('current_lesson', widget.lesson);
// //     if (mounted) {
// //       setState(() {
// //         rewords = response
// //             .map<String>((e) => e['word'].toString().toLowerCase())
// //             .toList();
// //       });
// //     }
// //   }

// //   List<String> _splitSentences(String text) {
// //     return text
// //         .split(RegExp(r'(?<=[.!?])\s+'))
// //         .map((s) => s.trim())
// //         .where((s) => s.isNotEmpty)
// //         .toList();
// //   }

// //   Future<void> _loadLessonWords() async {
// //     final response = await supabase
// //         .from('z_words_all')
// //         .select('word')
// //         .eq('level', widget.level)
// //         .eq('lesson', widget.lesson);
// //     if (mounted) {
// //       setState(() {
// //         lessonWords = response
// //             .map<String>((e) => e['word'].toString().toLowerCase())
// //             .toList();
// //       });
// //     }
// //   }

// //   Future<StoryContent> _fetchContent() async {
// //     try {
// //       final results = await Future.wait<dynamic>([
// //         supabase.from('z_stories').select().eq('id', widget.storyId).single(),
// //         supabase.from('z_qestions').select().eq('story_id', widget.storyId),
// //         supabase
// //             .from('z_words_all')
// //             .select('word')
// //             .eq('level', widget.level)
// //             .eq('lesson', widget.lesson),
// //       ]);

// //       final storyData = results[0] as Map<String, dynamic>;
// //       final questionsData = results[1] as List<dynamic>;
// //       final wordsData = results[2] as List<dynamic>;

// //       return StoryContent.fromRawSupabaseData(
// //         storyData: storyData,
// //         questionsData: questionsData,
// //         wordsData: wordsData,
// //       );
// //     } catch (e) {
// //       throw Exception('Failed to load content: $e');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return FutureBuilder<StoryContent>(
// //       future: _contentFuture,
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Scaffold(
// //             body: Center(child: CircularProgressIndicator()),
// //           );
// //         }

// //         if (snapshot.hasError) {
// //           return Scaffold(
// //             appBar: AppBar(title: const Text('خطأ')),
// //             body:
// //                 Center(child: Text('خطأ في تحميل المحتوى: ${snapshot.error}')),
// //           );
// //         }

// //         final content = snapshot.data!;

// //         final writingQuestions = [
// //           ...content.comprehensionOpenEndedQuestions,
// //           ...content.vocabularyFillInTheBlankQuestions,
// //         ];
// //         final mcqQuestions = [
// //           ...content.comprehensionQuestions,
// //           ...content.vocabularyQuestions,
// //         ];

// //         return DefaultTabController(
// //           length: 4,
// //           child: Scaffold(
// //             appBar: AppBar(
// //               title: Text(content.storyTitle),
// //               bottom: const TabBar(
// //                 tabs: [
// //                   Tab(icon: Icon(Icons.menu_book), text: 'القصة'),
// //                   Tab(icon: Icon(Icons.edit), text: 'أسئلة'),
// //                   Tab(icon: Icon(Icons.check_circle_outline), text: 'أسئلة'),
// //                   Tab(icon: Icon(Icons.list_alt), text: 'كلمات'),
// //                 ],
// //               ),
// //             ),
// //             body: TabBarView(
// //               children: [
// //                 SingleChildScrollView(
// //                   padding: const EdgeInsets.all(8.0),
// //                   child: Column(
// //                     children: [
// //                       _buildSectionCard(
// //                         context,
// //                         'القصة',
// //                         Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             // أزرار التشغيل
// //                             // Row(
// //                             //   children: [
// //                             //     ElevatedButton.icon(
// //                             //       onPressed: () => _speak(content.storyEn),
// //                             //       icon: Icon(isSpeakingNormal
// //                             //           ? Icons.pause
// //                             //           : Icons.play_arrow),
// //                             //       label: const Text(""),
// //                             //       style: ElevatedButton.styleFrom(
// //                             //           minimumSize: Size(40, 40)),
// //                             //     ),
// //                             //     const SizedBox(width: 10),
// //                             //     ElevatedButton.icon(
// //                             //       onPressed: () => _speakSlow(content.storyEn),
// //                             //       icon: Icon(isSpeakingSlow
// //                             //           ? Icons.pause
// //                             //           : Icons.slow_motion_video),
// //                             //       label: const Text(""),
// //                             //       style: ElevatedButton.styleFrom(
// //                             //           minimumSize: Size(40, 40)),
// //                             //     ),
// //                             //   ],
// //                             // ),
// // // file: lib/screens/content_screen.dart in build method

// // // ... داخل child الخاص بـ Column في _buildSectionCard
// //                             Row(
// //                               children: [
// //                                 ElevatedButton.icon(
// //                                   // --- التعديل هنا ---
// //                                   onPressed: () {
// //                                     if (isSpeakingNormal) {
// //                                       _stopSpeaking();
// //                                     } else {
// //                                       _speak(
// //                                           content.storyEn); // نمرر النص الكامل
// //                                     }
// //                                   },
// //                                   icon: Icon(isSpeakingNormal
// //                                       ? Icons.pause
// //                                       : Icons.play_arrow),
// //                                   label: const Text(""),
// //                                   style: ElevatedButton.styleFrom(
// //                                       minimumSize: const Size(40, 40)),
// //                                 ),
// //                                 const SizedBox(width: 10),
// //                                 ElevatedButton.icon(
// //                                   // --- التعديل هنا ---
// //                                   onPressed: () {
// //                                     if (isSpeakingSlow) {
// //                                       _stopSpeaking();
// //                                     } else {
// //                                       _speakSlow(
// //                                           content.storyEn); // نمرر النص الكامل
// //                                     }
// //                                   },
// //                                   icon: Icon(isSpeakingSlow
// //                                       ? Icons.pause
// //                                       : Icons.slow_motion_video),
// //                                   label: const Text(""),
// //                                   style: ElevatedButton.styleFrom(
// //                                       minimumSize: const Size(40, 40)),
// //                                 ),
// //                               ],
// //                             ),
// //                             const SizedBox(height: 10),

// //                             // جدول الجمل
// //                             Table(
// //                               columnWidths: const {
// //                                 0: FlexColumnWidth(1),
// //                                 1: FlexColumnWidth(1),
// //                               },
// //                               border:
// //                                   TableBorder.all(color: Colors.grey.shade300),
// //                               children: List.generate(
// //                                 _splitSentences(content.storyEn).length,
// //                                 (index) {
// //                                   final enSentences =
// //                                       _splitSentences(content.storyEn);
// //                                   final arSentences =
// //                                       _splitSentences(content.storyAr);

// //                                   final enSentence = enSentences[index];
// //                                   final arSentence = index < arSentences.length
// //                                       ? arSentences[index]
// //                                       : "";

// //                                   return TableRow(
// //                                     decoration: BoxDecoration(
// //                                       color: currentSpokenIndex == index
// //                                           ? Colors.yellow[100]
// //                                           : null,
// //                                     ),
// //                                     children: [
// //                                       Padding(
// //                                         padding: const EdgeInsets.all(8.0),
// //                                         child: Text(
// //                                           arSentence,
// //                                           textDirection: TextDirection.rtl,
// //                                           style: Theme.of(context)
// //                                               .textTheme
// //                                               .bodyMedium,
// //                                         ),
// //                                       ),
// //                                       Padding(
// //                                         padding: const EdgeInsets.all(8.0),
// //                                         child: RichText(
// //                                           text: _buildHighlightedText(
// //                                             enSentence,
// //                                             lessonWords,
// //                                             Theme.of(context)
// //                                                 .textTheme
// //                                                 .bodyMedium!,
// //                                           ),
// //                                           textDirection: TextDirection.ltr,
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   );
// //                                 },
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 ListView.builder(
// //                   padding: const EdgeInsets.all(8.0),
// //                   itemCount: writingQuestions.length,
// //                   itemBuilder: (context, index) =>
// //                       WritingQuizCard(questionData: writingQuestions[index]),
// //                 ),
// //                 ListView.builder(
// //                   padding: const EdgeInsets.all(8.0),
// //                   itemCount: mcqQuestions.length,
// //                   itemBuilder: (context, index) =>
// //                       MultipleChoiceQuizCard(questionData: mcqQuestions[index]),
// //                 ),
// //                 ListView.builder(
// //                   padding: const EdgeInsets.all(8.0),
// //                   itemCount: lessonWords.length,
// //                   itemBuilder: (context, index) {
// //                     final word = lessonWords[index];
// //                     return ListTile(
// //                       title: Text(word),
// //                       trailing: IconButton(
// //                         icon: const Icon(Icons.volume_up),
// //                         onPressed: () => _speak(word),
// //                       ),
// //                       onLongPress: () => _showWordOptions(word),
// //                     );
// //                   },
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Card _buildSectionCard(BuildContext context, String title, Widget child) {
// //     return Card(
// //       child: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(title,
// //                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
// //                     fontWeight: FontWeight.bold,
// //                     color: Theme.of(context).primaryColor)),
// //             const Divider(height: 20),
// //             SizedBox(width: double.infinity, child: child),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ✅ الدالة المعدلة لجعل كل الكلمات قابلة للتحديد
// //   TextSpan _buildHighlightedText(
// //       String text, List<String> blueWords, TextStyle defaultStyle) {
// //     final spans = <TextSpan>[];
// //     final wordRegex = RegExp(r"[a-zA-Z]+");

// //     int lastMatchEnd = 0;
// //     for (final Match match in wordRegex.allMatches(text)) {
// //       if (match.start > lastMatchEnd) {
// //         final String nonWord = text.substring(lastMatchEnd, match.start);
// //         spans.add(TextSpan(text: nonWord, style: defaultStyle));
// //       }

// //       final String word = match.group(0)!;
// //       final String lowerCaseWord = word.toLowerCase();

// //       TextStyle style;
// //       if (blueWords.contains(lowerCaseWord)) {
// //         style = defaultStyle.copyWith(
// //             color: Colors.blue, fontWeight: FontWeight.bold);
// //       } else if (rewords.contains(lowerCaseWord)) {
// //         style = defaultStyle.copyWith(
// //             color: Colors.green, fontWeight: FontWeight.bold);
// //       } else {
// //         style = defaultStyle;
// //       }

// //       spans.add(
// //         TextSpan(
// //           text: word,
// //           style: style,
// //           recognizer: LongPressGestureRecognizer()
// //             ..onLongPress = () {
// //               _showWordOptions(word);
// //             },
// //         ),
// //       );

// //       lastMatchEnd = match.end;
// //     }

// //     if (lastMatchEnd < text.length) {
// //       spans.add(
// //           TextSpan(text: text.substring(lastMatchEnd), style: defaultStyle));
// //     }

// //     return TextSpan(children: spans);
// //   }

// //   void _showWordOptions(String word) async {
// //     final translation =
// //         await _translateWord(word); // <-- سيتم استدعاء دالة الترجمة الجديدة
// //     if (!mounted) return;
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text(word),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text("الترجمة: $translation"),
// //             const SizedBox(height: 10),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: [
// //                 IconButton(
// //                   icon: const Icon(Icons.volume_up),
// //                   tooltip: 'تشغيل الصوت',
// //                   onPressed: () => _speak(word),
// //                 ),
// //                 IconButton(
// //                   icon: const Icon(Icons.slow_motion_video),
// //                   tooltip: 'تشغيل صوت بطيء',
// //                   onPressed: () => _speakSlow(word),
// //                 ),
// //                 IconButton(
// //                   icon: const Icon(Icons.add_circle_outline),
// //                   tooltip: 'إضافة إلى كلمات الدرس',
// //                   onPressed: () => _addWordToDatabase(word),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Future<void> _addWordToDatabase(String word) async {
// //     final confirm = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('تأكيد الإضافة'),
// //         content: Text('هل تريد إضافة "$word" إلى كلمات الدرس؟'),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context, false),
// //             child: const Text('إلغاء'),
// //           ),
// //           ElevatedButton(
// //             onPressed: () => Navigator.pop(context, true),
// //             child: const Text('تأكيد'),
// //           ),
// //         ],
// //       ),
// //     );

// //     if (confirm == true) {
// //       await supabase.from('z_words_all').insert({
// //         'word': word,
// //         'level': widget.level,
// //         'lesson': widget.lesson,
// //         'is_add': 1,
// //       });

// //       if (mounted) {
// //         Navigator.pop(context); // إغلاق نافذة الخيارات بعد الإضافة
// //       }
// //     }
// //   }

// //   Future<void> _speak(String fullText) async {
// //     // إذا كان وضع التحدث البطيء نشط، أوقفه
// //     if (isSpeakingSlow) {
// //       _isCancelled = true;
// //       await tts.stop();
// //       await Future.delayed(Duration(milliseconds: 300));
// //     }

// //     _isCancelled = false;
// //     setState(() {
// //       isSpeakingNormal = true;
// //       isSpeakingSlow = false;
// //       currentSpokenIndex = null;
// //     });

// //     await tts.setSpeechRate(1);
// //     if (_maleVoice == null || _femaleVoice == null) {
// //       await _loadAvailableVoices();
// //     }

// //     List<String> sentences = _splitSentences(fullText);

// //     for (int i = 0; i < sentences.length; i++) {
// //       if (_isCancelled) break;

// //       setState(() {
// //         currentSpokenIndex = i;
// //       });

// //       String sentence = sentences[i].trim();
// //       if (sentence.isEmpty) continue;

// //       if (i % 2 == 0 && _maleVoice != null) {
// //         await tts.setVoice({'name': _maleVoice!, 'locale': 'en-US'});
// //       } else if (_femaleVoice != null) {
// //         await tts.setVoice({'name': _femaleVoice!, 'locale': 'en-US'});
// //       }

// //       await tts.speak(sentence);
// //       await _waitForSpeechCompletion();
// //     }

// //     setState(() {
// //       isSpeakingNormal = false;
// //       currentSpokenIndex = null;
// //     });
// //   }

// //   Future<void> _speakSlow(String fullText) async {
// //     // إذا كان الوضع العادي نشط، أوقفه
// //     if (isSpeakingNormal) {
// //       _isCancelled = true;
// //       await tts.stop();
// //       await Future.delayed(Duration(milliseconds: 300));
// //     }

// //     _isCancelled = false;
// //     setState(() {
// //       isSpeakingSlow = true;
// //       isSpeakingNormal = false;
// //       currentSpokenIndex = null;
// //     });

// //     await tts.setSpeechRate(0.5);
// //     if (_maleVoice == null || _femaleVoice == null) {
// //       await _loadAvailableVoices();
// //     }

// //     List<String> sentences = _splitSentences(fullText);

// //     for (int i = 0; i < sentences.length; i++) {
// //       if (_isCancelled) break;

// //       setState(() {
// //         currentSpokenIndex = i;
// //       });

// //       String sentence = sentences[i].trim();
// //       if (sentence.isEmpty) continue;

// //       if (i % 2 == 0 && _maleVoice != null) {
// //         await tts.setVoice({'name': _maleVoice!, 'locale': 'en-US'});
// //       } else if (_femaleVoice != null) {
// //         await tts.setVoice({'name': _femaleVoice!, 'locale': 'en-US'});
// //       }

// //       await tts.speak(sentence);
// //       await _waitForSpeechCompletion();
// //     }

// //     setState(() {
// //       isSpeakingSlow = false;
// //       currentSpokenIndex = null;
// //     });
// //   }

// //   // Future<void> _speak(String fullText) async {
// //   //   _isCancelled = false;
// //   //   setState(() {
// //   //     isSpeakingNormal = true;
// //   //     currentSpokenIndex = null;
// //   //   });

// //   //   await tts.setSpeechRate(1);
// //   //   if (_maleVoice == null || _femaleVoice == null) {
// //   //     await _loadAvailableVoices();
// //   //   }

// //   //   List<String> sentences = _splitSentences(fullText);

// //   //   for (int i = 0; i < sentences.length; i++) {
// //   //     if (_isCancelled) break;

// //   //     setState(() {
// //   //       currentSpokenIndex = i;
// //   //     });

// //   //     String sentence = sentences[i].trim();
// //   //     if (sentence.isEmpty) continue;

// //   //     if (i % 2 == 0 && _maleVoice != null) {
// //   //       await tts.setVoice({'name': _maleVoice!, 'locale': 'en-US'});
// //   //     } else if (_femaleVoice != null) {
// //   //       await tts.setVoice({'name': _femaleVoice!, 'locale': 'en-US'});
// //   //     }

// //   //     await tts.speak(sentence);
// //   //     await _waitForSpeechCompletion();
// //   //   }

// //   //   setState(() {
// //   //     isSpeakingNormal = false;
// //   //     currentSpokenIndex = null;
// //   //   });
// //   // }

// //   // Future<void> _speakSlow(String fullText) async {
// //   //   _isCancelled = false;
// //   //   setState(() {
// //   //     isSpeakingSlow = true;
// //   //     currentSpokenIndex = null;
// //   //   });

// //   //   await tts.setSpeechRate(0.5);
// //   //   if (_maleVoice == null || _femaleVoice == null) {
// //   //     await _loadAvailableVoices();
// //   //   }

// //   //   List<String> sentences = _splitSentences(fullText);

// //   //   for (int i = 0; i < sentences.length; i++) {
// //   //     if (_isCancelled) break;

// //   //     setState(() {
// //   //       currentSpokenIndex = i;
// //   //     });

// //   //     String sentence = sentences[i].trim();
// //   //     if (sentence.isEmpty) continue;

// //   //     if (i % 2 == 0 && _maleVoice != null) {
// //   //       await tts.setVoice({'name': _maleVoice!, 'locale': 'en-US'});
// //   //     } else if (_femaleVoice != null) {
// //   //       await tts.setVoice({'name': _femaleVoice!, 'locale': 'en-US'});
// //   //     }

// //   //     await tts.speak(sentence);
// //   //     await _waitForSpeechCompletion();
// //   //   }

// //   //   setState(() {
// //   //     isSpeakingSlow = false;
// //   //     currentSpokenIndex = null;
// //   //   });
// //   // }

// //   Future<void> _waitForSpeechCompletion() {
// //     final completer = Completer<void>();

// //     tts.setCompletionHandler(() {
// //       completer.complete();
// //     });

// //     return completer.future;
// //   }

// //   Future<void> printAvailableVoices() async {
// //     var voices = await tts.getVoices;
// //     for (var voice in voices) {
// //       print(voice);
// //     }
// //   }

// //   Future<void> _stopSpeaking() async {
// //     await tts.stop();
// //     _isCancelled = true;
// //     setState(() {
// //       isSpeakingNormal = false;
// //       isSpeakingSlow = false;
// //       currentSpokenIndex = null;
// //     });
// //   }

// //   Future<void> _loadAvailableVoices() async {
// //     final voices = await tts
// //         .getVoices; // غالبًا ترجع List<dynamic> من خرائط فيها name و locale
// //     if (voices is List) {
// //       // بحث بسيط عن أسماء تدل على أنثى أو ذكر
// //       for (var v in voices) {
// //         final name = (v['name'] ?? '').toString().toLowerCase();
// //         if (_maleVoice == null &&
// //             (name.contains('male') ||
// //                 name.contains('man') ||
// //                 name.contains('david') ||
// //                 name.contains('mark'))) {
// //           _maleVoice = v['name'];
// //         }
// //         if (_femaleVoice == null &&
// //             (name.contains('female') ||
// //                 name.contains('woman') ||
// //                 name.contains('zira'))) {
// //           _femaleVoice = v['name'];
// //         }
// //         if (_maleVoice != null && _femaleVoice != null) break;
// //       }

// //       // إذا ما لقين فلترة واضحة، خذ أولين مختلفين كـ fallback
// //       if (_maleVoice == null && voices.isNotEmpty) {
// //         _maleVoice = voices[0]['name'];
// //       }
// //       if (_femaleVoice == null && voices.length > 1) {
// //         _femaleVoice = voices[1]['name'];
// //       }
// //     }
// //   }

// // // هذا الكود متوافق فقط مع الإصدار القديم 1.0.0
// //   Future<String> _translateWord(String word) async {
// //     // لاحظ أننا ننشئ كائنًا جديدًا من المترجم أولاً
// //     final translator = GoogleTranslator();

// //     try {
// //       var translation = await translator.translate(word, from: 'en', to: 'ar');
// //       return translation.text;
// //     } catch (e) {
// //       print("Translation Error: $e");
// //       return "فشل في الترجمة";
// //     }
// //   }
// // }


// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ///
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:translator/translator.dart';
// import '../main.dart'; // For supabase instance
// import '../models/story_content_model.dart'; // For StoryContent model
// import '../widgets/quiz_widgets.dart'; // For Quiz Cards
// import 'dart:async';

// class ContentScreen extends StatefulWidget {
//   final int storyId;
//   final int level;
//   final int lesson;

//   const ContentScreen({
//     super.key,
//     required this.storyId,
//     required this.level,
//     required this.lesson,
//   });

//   @override
//   State<ContentScreen> createState() => _ContentScreenState();
// }

// class _ContentScreenState extends State<ContentScreen> {
//   late Future<StoryContent> _contentFuture;
//   List<String> rewords = [];
//   List<String> lessonWords = [];
//   final FlutterTts tts = FlutterTts();
//   bool _isCancelled = false;

//   // TTS State
//   String? _maleVoice;
//   String? _femaleVoice;
//   int? currentSpokenIndex;
//   bool isSpeakingNormal = false;
//   bool isSpeakingSlow = false;

//   @override
//   void initState() {
//     super.initState();
//     _contentFuture = _fetchContent();
//     _loadRewords();
//     _loadLessonWords();
//     _initTTS();
//   }

//   @override
//   void dispose() {
//     // Ensure TTS is stopped when the screen is disposed to prevent memory leaks
//     tts.stop();
//     super.dispose();
//   }

//   Future<void> _initTTS() async {
//     await tts.setLanguage("en-US");
//     await tts.setPitch(1.0);
//     await _loadAvailableVoices();
//   }

//   Future<StoryContent> _fetchContent() async {
//     try {
//       final results = await Future.wait<dynamic>([
//         supabase.from('z_stories').select().eq('id', widget.storyId).single(),
//         supabase.from('z_qestions').select().eq('story_id', widget.storyId),
//         supabase
//             .from('z_words_all')
//             .select('word')
//             .eq('level', widget.level)
//             .eq('lesson', widget.lesson),
//       ]);

//       final storyData = results[0] as Map<String, dynamic>;
//       final questionsData = results[1] as List<dynamic>;
//       final wordsData = results[2] as List<dynamic>;

//       // Uses the updated factory constructor from the model
//       return StoryContent.fromRawSupabaseData(
//         storyData: storyData,
//         questionsData: questionsData,
//         wordsData: wordsData,
//       );
//     } catch (e) {
//       // Provide a more user-friendly error message
//       debugPrint('Error fetching content: $e');
//       throw Exception('فشل في تحميل محتوى القصة. يرجى المحاولة مرة أخرى.');
//     }
//   }

//   Future<void> _loadRewords() async {
//     final response = await supabase
//         .from('rewords')
//         .select('word')
//         .eq('level', widget.level)
//         .eq('current_lesson', widget.lesson);
//     if (mounted) {
//       setState(() {
//         rewords = response
//             .map<String>((e) => e['word'].toString().toLowerCase())
//             .toList();
//       });
//     }
//   }

//   Future<void> _loadLessonWords() async {
//     final response = await supabase
//         .from('z_words_all')
//         .select('word')
//         .eq('level', widget.level)
//         .eq('lesson', widget.lesson);
//     if (mounted) {
//       setState(() {
//         lessonWords = response
//             .map<String>((e) => e['word'].toString().toLowerCase())
//             .toList();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<StoryContent>(
//       future: _contentFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (snapshot.hasError) {
//           return Scaffold(
//             appBar: AppBar(title: const Text('خطأ')),
//             body: Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   'حدث خطأ: ${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               ),
//             ),
//           );
//         }

//         final content = snapshot.data!;

//         // تجميع قوائم الأسئلة للعرض في الألسنة المخصصة
//         final writingQuestions = [
//           ...content.comprehensionOpenEndedQuestions,
//           ...content.vocabularyFillInTheBlankQuestions,
//         ];
        
//         final mcqQuestions = [
//           ...content.comprehensionQuestions,
//           ...content.vocabularyQuestions,
//         ];

//         return DefaultTabController(
//           length: 4,
//           child: Scaffold(
//             appBar: AppBar(
//               title: Text(content.storyTitle),
//               bottom: const TabBar(
//                 isScrollable: false,
//                 tabs: [
//                   Tab(icon: Icon(Icons.menu_book), text: 'القصة'),
//                   Tab(icon: Icon(Icons.edit), text: 'كتابة'),
//                   Tab(icon: Icon(Icons.check_circle_outline), text: 'اختياري'),
//                   Tab(icon: Icon(Icons.list_alt), text: 'كلمات'),
//                 ],
//               ),
//             ),
//             body: TabBarView(
//               children: [
//                 // --- Tab 1: Story Content ---
//                 SingleChildScrollView(
//                   padding: const EdgeInsets.all(8.0),
//                   child: _buildStoryTab(content),
//                 ),

//                 // --- Tab 2: Writing Questions ---

//                 ListView.builder(
//                   padding: const EdgeInsets.all(8.0),
//                   itemCount: writingQuestions.length,
//                   itemBuilder: (context, index) {
//                     // This assumes you have a generic quiz card that can handle both types
//                     // or you can use an `if` statement to check the type
//                     final question = writingQuestions[index];
//                     if (question is OpenEndedQuestion) {
//                       return WritingQuizCard(questionData: question);
//                     } else if (question is FillInTheBlankQuestion) {
//                       return WritingQuizCard(questionData: question);
//                     }
//                     return const SizedBox.shrink(); // Should not happen
//                   },
//                 ),

//                 // --- Tab 3: Multiple Choice Questions ---
              
//                 ListView.builder(
//                   padding: const EdgeInsets.all(8.0),
//                   itemCount: mcqQuestions.length,
//                   itemBuilder: (context, index) {
//                     final question = mcqQuestions[index];
//                      if (question is ComprehensionQuestion) {
//                       return MultipleChoiceQuizCard(questionData: question);
//                     } else if (question is VocabularyQuestion) {
//                       return MultipleChoiceQuizCard(questionData: question);
//                     }
//                     return const SizedBox.shrink(); // Should not happen
//                   },
//                 ),

//                 // --- Tab 4: Vocabulary List ---
//                 ListView.builder(
//                   padding: const EdgeInsets.all(8.0),
//                   itemCount: lessonWords.length,
//                   itemBuilder: (context, index) {
//                     final word = lessonWords[index];
//                     return Card(
//                       child: ListTile(
//                         title: Text(word, style: const TextStyle(fontWeight: FontWeight.bold)),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.volume_up),
//                           onPressed: () => _speakSingleWord(word),
//                         ),
//                         onLongPress: () => _showWordOptions(word),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // --- Widget Builders ---

//   Widget _buildStoryTab(StoryContent content) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Audio Control Buttons
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     if (isSpeakingNormal) {
//                       _stopSpeaking();
//                     } else {
//                       _speakStory(content.storyContent);
//                     }
//                   },
//                   icon: Icon(isSpeakingNormal ? Icons.pause_circle_filled : Icons.play_circle_filled),
//                   label: const Text("عادي"),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     if (isSpeakingSlow) {
//                       _stopSpeaking();
//                     } else {
//                       _speakStorySlow(content.storyContent);
//                     }
//                   },
//                   icon: Icon(isSpeakingSlow ? Icons.pause_circle : Icons.slow_motion_video),
//                   label: const Text("بطيء"),
//                 ),
//               ],
//             ),
//             const Divider(height: 30, thickness: 1),

//             // Sentences Table
//             Table(
//               columnWidths: const {
//                 0: FlexColumnWidth(1),
//                 1: FlexColumnWidth(1),
//               },
//               border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
//               children: List.generate(
//                 content.storyContent.length,
//                 (index) {
//                   final sentencePair = content.storyContent[index];
//                   return TableRow(
//                     decoration: BoxDecoration(
//                       color: currentSpokenIndex == index ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
//                     ),
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Text(
//                           sentencePair.ar,
//                           textDirection: TextDirection.rtl,
//                           style: const TextStyle(fontSize: 16, height: 1.5),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: RichText(
//                           text: _buildHighlightedText(
//                             sentencePair.en,
//                             Theme.of(context).textTheme.bodyLarge!,
//                           ),
//                           textDirection: TextDirection.ltr,
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   TextSpan _buildHighlightedText(String text, TextStyle defaultStyle) {
//     final spans = <TextSpan>[];
//     final wordRegex = RegExp(r"([a-zA-Z]+)(['-]?[a-zA-Z]+)*");

//     int lastMatchEnd = 0;
//     for (final Match match in wordRegex.allMatches(text)) {
//       if (match.start > lastMatchEnd) {
//         spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: defaultStyle));
//       }
//       final String word = match.group(0)!;
//       final String lowerCaseWord = word.toLowerCase();
//       TextStyle style;
//       if (lessonWords.contains(lowerCaseWord)) {
//         style = defaultStyle.copyWith(color: Colors.blue, fontWeight: FontWeight.bold);
//       } else if (rewords.contains(lowerCaseWord)) {
//         style = defaultStyle.copyWith(color: Colors.green, fontWeight: FontWeight.bold);
//       } else {
//         style = defaultStyle;
//       }

//       spans.add(
//         TextSpan(
//           text: word,
//           style: style,
//           recognizer: LongPressGestureRecognizer()..onLongPress = () => _showWordOptions(word),
//         ),
//       );
//       lastMatchEnd = match.end;
//     }

//     if (lastMatchEnd < text.length) {
//       spans.add(TextSpan(text: text.substring(lastMatchEnd), style: defaultStyle));
//     }
//     return TextSpan(children: spans, style: const TextStyle(fontSize: 16, height: 1.5));
//   }

//   // --- Word Interaction ---

//   void _showWordOptions(String word) async {
//     final translation = await _translateWord(word);
//     if (!mounted) return;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(word),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("الترجمة: $translation", style: const TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 IconButton(icon: const Icon(Icons.volume_up), tooltip: 'تشغيل الصوت', onPressed: () => _speakSingleWord(word)),
//                 IconButton(icon: const Icon(Icons.add_circle_outline), tooltip: 'إضافة للمراجعة', onPressed: () => _addWordToDatabase(word)),
//               ],
//             ),
//           ],
//         ),
//         actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))],
//       ),
//     );
//   }

//   Future<void> _addWordToDatabase(String word) async {
//     // Logic to add the word to a review list or another table
//     Navigator.pop(context); // Close the dialog first
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('تمت إضافة "$word" للمراجعة (وظيفة افتراضية).')),
//     );
//   }

//   Future<String> _translateWord(String word) async {
//     final translator = GoogleTranslator();
//     try {
//       var translation = await translator.translate(word, from: 'en', to: 'ar');
//       return translation.text;
//     } catch (e) {
//       return "فشل الترجمة";
//     }
//   }

//   // --- TTS (Text-to-Speech) Functions ---

//   Future<void> _speakStory(List<SentencePair> sentences) async {
//     if (isSpeakingSlow) await _stopSpeaking();
//     _isCancelled = false;
//     setState(() {
//       isSpeakingNormal = true;
//       isSpeakingSlow = false;
//     });
//     await tts.setSpeechRate(0.5); // Normal speed

//     for (int i = 0; i < sentences.length; i++) {
//       if (_isCancelled) break;
//       if(mounted) setState(() => currentSpokenIndex = i);

//       final sentence = sentences[i].en.trim();
//       if (sentence.isEmpty) continue;

//       if (i % 2 == 0 && _maleVoice != null) {
//         await tts.setVoice({'name': _maleVoice!, 'locale': 'en-US'});
//       } else if (_femaleVoice != null) {
//         await tts.setVoice({'name': _femaleVoice!, 'locale': 'en-US'});
//       }
      
//       await tts.speak(sentence);
//       await _waitForSpeechCompletion();
//     }
//     if (mounted && !_isCancelled) _stopSpeaking();
//   }

//   Future<void> _speakStorySlow(List<SentencePair> sentences) async {
//     if (isSpeakingNormal) await _stopSpeaking();
//     _isCancelled = false;
//     setState(() {
//       isSpeakingNormal = false;
//       isSpeakingSlow = true;
//     });
//     await tts.setSpeechRate(0.25); // Slower speed

//     for (int i = 0; i < sentences.length; i++) {
//       if (_isCancelled) break;
//        if(mounted) setState(() => currentSpokenIndex = i);

//       final sentence = sentences[i].en.trim();
//       if (sentence.isEmpty) continue;
      
//       await tts.speak(sentence);
//       await _waitForSpeechCompletion();
//     }

//     if (mounted && !_isCancelled) _stopSpeaking();
//   }
  
//   Future<void> _speakSingleWord(String word) async {
//     await tts.setSpeechRate(0.4); // A good speed for single words
//     await tts.speak(word);
//   }

//   Future<void> _stopSpeaking() async {
//     _isCancelled = true;
//     await tts.stop();
//     if (mounted) {
//       setState(() {
//         isSpeakingNormal = false;
//         isSpeakingSlow = false;
//         currentSpokenIndex = null;
//       });
//     }
//   }

//   Future<void> _waitForSpeechCompletion() {
//     final completer = Completer<void>();
//     tts.setCompletionHandler(() {
//       if (!completer.isCompleted) completer.complete();
//     });
//     return completer.future;
//   }

//   Future<void> _loadAvailableVoices() async {
//     final voices = await tts.getVoices as List;
//     final englishVoices = voices.where((v) => (v['locale'] as String).startsWith('en-')).toList();

//     if (englishVoices.isNotEmpty) {
//       _maleVoice = englishVoices.firstWhere((v) => (v['name'] as String).toLowerCase().contains('male'), orElse: () => englishVoices.first)['name'];
//       _femaleVoice = englishVoices.firstWhere((v) => (v['name'] as String).toLowerCase().contains('female'), orElse: () => englishVoices.length > 1 ? englishVoices[1] : englishVoices.first)['name'];
//     }
//   }
// }
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import '../main.dart'; // For supabase instance
import '../models/story_content_model.dart'; // For StoryContent model
import '../widgets/quiz_widgets.dart'; // For Quiz Cards
import 'dart:async';

class ContentScreen extends StatefulWidget {
  final int storyId;
  final int level;
  final int lesson;

  const ContentScreen({
    super.key,
    required this.storyId,
    required this.level,
    required this.lesson,
  });

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  late Future<StoryContent> _contentFuture;
  List<String> rewords = [];
  List<String> lessonWords = [];
  final FlutterTts tts = FlutterTts();
  bool _isCancelled = false;

  // TTS State
  String? _maleVoice;
  String? _femaleVoice;
  int? currentSpokenIndex;
  bool isSpeakingNormal = false;
  bool isSpeakingSlow = false;

  @override
  void initState() {
    super.initState();
    _contentFuture = _fetchContent();
    _loadRewords();
    _loadLessonWords();
    _initTTS();
  }

  @override
  void dispose() {
    // Ensure TTS is stopped when the screen is disposed to prevent memory leaks
    tts.stop();
    super.dispose();
  }

  Future<void> _initTTS() async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0);
    await _loadAvailableVoices();
  }

  Future<StoryContent> _fetchContent() async {
    try {
      final results = await Future.wait<dynamic>([
        supabase.from('z_stories').select().eq('id', widget.storyId).single(),
        supabase.from('z_qestions').select().eq('story_id', widget.storyId),
        supabase
            .from('z_words_all')
            .select('word')
            .eq('level', widget.level)
            .eq('lesson', widget.lesson),
      ]);

      final storyData = results[0] as Map<String, dynamic>;
      final questionsData = results[1] as List<dynamic>;
      final wordsData = results[2] as List<dynamic>;

      // Uses the updated factory constructor from the model
      return StoryContent.fromRawSupabaseData(
        storyData: storyData,
        questionsData: questionsData,
        wordsData: wordsData,
      );
    } catch (e) {
      // Provide a more user-friendly error message
      debugPrint('Error fetching content: $e');
      throw Exception('فشل في تحميل محتوى القصة. يرجى المحاولة مرة أخرى.');
    }
  }

  Future<void> _loadRewords() async {
    final response = await supabase
        .from('rewords')
        .select('word')
        .eq('level', widget.level)
        .eq('current_lesson', widget.lesson);
    if (mounted) {
      setState(() {
        rewords = response
            .map<String>((e) => e['word'].toString().toLowerCase())
            .toList();
      });
    }
  }

  Future<void> _loadLessonWords() async {
    final response = await supabase
        .from('z_words_all')
        .select('word')
        .eq('level', widget.level)
        .eq('lesson', widget.lesson);
    if (mounted) {
      setState(() {
        lessonWords = response
            .map<String>((e) => e['word'].toString().toLowerCase())
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StoryContent>(
      future: _contentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('خطأ')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'حدث خطأ: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        final content = snapshot.data!;

        // تجميع قوائم الأسئلة للعرض في الألسنة المخصصة
        final writingQuestions = [
          ...content.comprehensionOpenEndedQuestions,
          ...content.vocabularyFillInTheBlankQuestions,
        ];

        final mcqQuestions = [
          ...content.comprehensionQuestions,
          ...content.vocabularyQuestions,
        ];

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text(content.storyTitle),
              bottom: const TabBar(
                isScrollable: false,
                tabs: [
                  Tab(icon: Icon(Icons.menu_book), text: 'القصة'),
                  Tab(icon: Icon(Icons.edit), text: 'كتابة'),
                  Tab(icon: Icon(Icons.check_circle_outline), text: 'اختياري'),
                  Tab(icon: Icon(Icons.list_alt), text: 'كلمات'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // --- Tab 1: Story Content ---
                SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildStoryTab(content),
                ),

                // --- Tab 2: Writing Questions ---
                ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: writingQuestions.length,
                  itemBuilder: (context, index) {
                    final question = writingQuestions[index];
                    // The generic WritingQuizCard can handle both types
                    return WritingQuizCard(questionData: question);
                  },
                ),

                // --- Tab 3: Multiple Choice Questions ---
                ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: mcqQuestions.length,
                  itemBuilder: (context, index) {
                    final question = mcqQuestions[index];
                    // The generic MultipleChoiceQuizCard can handle both types
                    return MultipleChoiceQuizCard(questionData: question);
                  },
                ),

                // --- Tab 4: Vocabulary List ---
                ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: lessonWords.length,
                  itemBuilder: (context, index) {
                    final word = lessonWords[index];
                    return Card(
                      child: ListTile(
                        title: Text(word,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                          icon: const Icon(Icons.volume_up),
                          onPressed: () => _speakSingleWord(word),
                        ),
                        onLongPress: () => _showWordOptions(word),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Widget Builders ---

  Widget _buildStoryTab(StoryContent content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audio Control Buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (isSpeakingNormal) {
                      _stopSpeaking();
                    } else {
                      _speakStory(content.storyContent);
                    }
                  },
                  icon: Icon(isSpeakingNormal
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled),
                  label: const Text("عادي"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    if (isSpeakingSlow) {
                      _stopSpeaking();
                    } else {
                      _speakStorySlow(content.storyContent);
                    }
                  },
                  icon: Icon(isSpeakingSlow
                      ? Icons.pause_circle
                      : Icons.slow_motion_video),
                  label: const Text("بطيء"),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),

            // Sentences Table
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
              },
              border: TableBorder.all(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8)),
              children: List.generate(
                content.storyContent.length,
                (index) {
                  final sentencePair = content.storyContent[index];
                  return TableRow(
                    decoration: BoxDecoration(
                      color: currentSpokenIndex == index
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : null,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          sentencePair.ar,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: RichText(
                          text: _buildHighlightedText(
                            sentencePair.en,
                            Theme.of(context).textTheme.bodyLarge!,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _buildHighlightedText(String text, TextStyle defaultStyle) {
    final spans = <TextSpan>[];
    final wordRegex = RegExp(r"([a-zA-Z]+)(['-]?[a-zA-Z]+)*");

    int lastMatchEnd = 0;
    for (final Match match in wordRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: defaultStyle));
      }
      final String word = match.group(0)!;
      final String lowerCaseWord = word.toLowerCase();
      TextStyle style;
      if (lessonWords.contains(lowerCaseWord)) {
        style = defaultStyle.copyWith(
            color: Colors.blue, fontWeight: FontWeight.bold);
      } else if (rewords.contains(lowerCaseWord)) {
        style = defaultStyle.copyWith(
            color: Colors.green, fontWeight: FontWeight.bold);
      } else {
        style = defaultStyle;
      }

      spans.add(
        TextSpan(
          text: word,
          style: style,
          recognizer: LongPressGestureRecognizer()
            ..onLongPress = () => _showWordOptions(word),
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(
          TextSpan(text: text.substring(lastMatchEnd), style: defaultStyle));
    }
    return TextSpan(
        children: spans, style: const TextStyle(fontSize: 16, height: 1.5));
  }

  // --- Word Interaction ---

  void _showWordOptions(String word) async {
    final translation = await _translateWord(word);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(word),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("الترجمة: $translation",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    icon: const Icon(Icons.volume_up),
                    tooltip: 'تشغيل الصوت',
                    onPressed: () => _speakSingleWord(word)),
                IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'إضافة للمراجعة',
                    onPressed: () => _addWordToDatabase(word)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'))
        ],
      ),
    );
  }

  Future<void> _addWordToDatabase(String word) async {
    // Logic to add the word to a review list or another table
    Navigator.pop(context); // Close the dialog first
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت إضافة "$word" للمراجعة (وظيفة افتراضية).')),
    );
  }

  Future<String> _translateWord(String word) async {
    final translator = GoogleTranslator();
    try {
      var translation = await translator.translate(word, from: 'en', to: 'ar');
      return translation.text;
    } catch (e) {
      return "فشل الترجمة";
    }
  }

  // --- TTS (Text-to-Speech) Functions ---

  Future<void> _speakStory(List<SentencePair> sentences) async {
    if (isSpeakingSlow) await _stopSpeaking();
    _isCancelled = false;
    setState(() {
      isSpeakingNormal = true;
      isSpeakingSlow = false;
    });
    await tts.setSpeechRate(1); // Normal speed

    for (int i = 0; i < sentences.length; i++) {
      if (_isCancelled) break;
      if (mounted) setState(() => currentSpokenIndex = i);

      final sentence = sentences[i].en.trim();
      if (sentence.isEmpty) continue;

      // if (i % 2 == 0 && _maleVoice != null) {
        await tts.setVoice({'name': 'en-us-x-sfg#male_1-local', 'locale': 'en-US'});
      // } else if (_femaleVoice != null) {
      //   await tts.setVoice({'name': _femaleVoice!, 'locale': 'en-US'});
      // }

      await tts.speak(sentence);
      await _waitForSpeechCompletion();
    }
    if (mounted && !_isCancelled) _stopSpeaking();
  }

  Future<void> _speakStorySlow(List<SentencePair> sentences) async {
    if (isSpeakingNormal) await _stopSpeaking();
    _isCancelled = false;
    setState(() {
      isSpeakingNormal = false;
      isSpeakingSlow = true;
    });
    await tts.setSpeechRate(0.5); // Slower speed

    for (int i = 0; i < sentences.length; i++) {
      if (_isCancelled) break;

      if (mounted) setState(() => currentSpokenIndex = i);

      final sentence = sentences[i].en.trim();
      if (sentence.isEmpty) continue;

      await tts.speak(sentence);
      await _waitForSpeechCompletion();
    }

    if (mounted && !_isCancelled) _stopSpeaking();
  }

  Future<void> _speakSingleWord(String word) async {
    await tts.setSpeechRate(1); // A good speed for single words
    await tts.speak(word);
  }

  Future<void> _stopSpeaking() async {
    _isCancelled = true;
    await tts.stop();
    if (mounted) {
      setState(() {
        isSpeakingNormal = false;
        isSpeakingSlow = false;
        currentSpokenIndex = null;
      });
    }
  }

  Future<void> _waitForSpeechCompletion() {
    final completer = Completer<void>();
    tts.setCompletionHandler(() {
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }

  Future<void> _loadAvailableVoices() async {
    final voices = await tts.getVoices as List;
    final englishVoices =
        voices.where((v) => (v['locale'] as String).startsWith('en-')).toList();

    if (englishVoices.isNotEmpty) {
      _maleVoice = englishVoices.firstWhere(
          (v) => (v['name'] as String).toLowerCase().contains('male'),
          orElse: () => englishVoices.first)['name'];
      _femaleVoice = englishVoices.firstWhere(
          (v) => (v['name'] as String).toLowerCase().contains('female'),
          orElse: () =>
              englishVoices.length > 1 ? englishVoices[1] : englishVoices.first)['name'];
    }
  }
}
