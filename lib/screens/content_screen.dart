
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import '../main.dart';
import '../models/story_content_model.dart';
import '../widgets/quiz_widgets.dart';

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

  @override
  void initState() {
    super.initState();
    _contentFuture = _fetchContent();
    _loadRewords();
    _loadLessonWords();
    _initTTS();
    printAvailableVoices();
  }

  Future<void> _initTTS() async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0);
  }

  Future<void> _loadRewords() async {
    final response = await supabase
        .from('rewords')
        .select('word')
        .eq('level', widget.level)
        .eq('current_lesson', widget.lesson);
    if (mounted) {
      setState(() {
        rewords = response.map<String>((e) => e['word'].toString().toLowerCase()).toList();
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
        lessonWords = response.map<String>((e) => e['word'].toString().toLowerCase()).toList();
      });
    }
  }

  Future<StoryContent> _fetchContent() async {
    try {
      final results = await Future.wait<dynamic>([
        supabase.from('z_stories').select().eq('id', widget.storyId).single(),
        supabase.from('z_qestions').select().eq('story_id', widget.storyId),
        supabase.from('z_words_all').select('word').eq('level', widget.level).eq('lesson', widget.lesson),
      ]);

      final storyData = results[0] as Map<String, dynamic>;
      final questionsData = results[1] as List<dynamic>;
      final wordsData = results[2] as List<dynamic>;

      return StoryContent.fromRawSupabaseData(
        storyData: storyData,
        questionsData: questionsData,
        wordsData: wordsData,
      );
    } catch (e) {
      throw Exception('Failed to load content: $e');
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
            body: Center(child: Text('خطأ في تحميل المحتوى: ${snapshot.error}')),
          );
        }

        final content = snapshot.data!;

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
                tabs: [
                  Tab(icon: Icon(Icons.menu_book), text: 'القصة'),
                  Tab(icon: Icon(Icons.edit), text: 'أسئلة كتابية'),
                  Tab(icon: Icon(Icons.check_circle_outline), text: 'أسئلة اختيارية'),
                  Tab(icon: Icon(Icons.list_alt), text: 'كلمات الدرس'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _buildSectionCard(
                        context,
                        'القصة بالإنجليزي',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => _speak(content.storyEn),
                                  child: const Text("تشغيل القصة"),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () => _speakSlow(content.storyEn),
                                  child: const Text("تشغيل ببطء"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            RichText(
                              text: _buildHighlightedText( // <-- ستعمل هذه الدالة الآن بشكل صحيح
                                content.storyEn,
                                lessonWords,
                                Theme.of(context).textTheme.bodyLarge!,
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                          ],
                        ),
                      ),
                      _buildSectionCard(
                        context,
                        'الترجمة',
                        Text(content.storyAr, style: Theme.of(context).textTheme.bodyLarge),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: writingQuestions.length,
                  itemBuilder: (context, index) => WritingQuizCard(questionData: writingQuestions[index]),
                ),
                ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: mcqQuestions.length,
                  itemBuilder: (context, index) => MultipleChoiceQuizCard(questionData: mcqQuestions[index]),
                ),
                ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: lessonWords.length,
                  itemBuilder: (context, index) {
                    final word = lessonWords[index];
                    return ListTile(
                      title: Text(word),
                      trailing: IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _speak(word),
                      ),
                      onLongPress: () => _showWordOptions(word),
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

  Card _buildSectionCard(BuildContext context, String title, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            const Divider(height: 20),
            SizedBox(width: double.infinity, child: child),
          ],
        ),
      ),
    );
  }

  // ✅ الدالة المعدلة لجعل كل الكلمات قابلة للتحديد
  TextSpan _buildHighlightedText(String text, List<String> blueWords, TextStyle defaultStyle) {
    final spans = <TextSpan>[];
    final wordRegex = RegExp(r"[a-zA-Z]+");

    int lastMatchEnd = 0;
    for (final Match match in wordRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        final String nonWord = text.substring(lastMatchEnd, match.start);
        spans.add(TextSpan(text: nonWord, style: defaultStyle));
      }

      final String word = match.group(0)!;
      final String lowerCaseWord = word.toLowerCase();

      TextStyle style;
      if (blueWords.contains(lowerCaseWord)) {
        style = defaultStyle.copyWith(color: Colors.blue, fontWeight: FontWeight.bold);
      } else if (rewords.contains(lowerCaseWord)) {
        style = defaultStyle.copyWith(color: Colors.green, fontWeight: FontWeight.bold);
      } else {
        style = defaultStyle;
      }

      spans.add(
        TextSpan(
          text: word,
          style: style,
          recognizer: LongPressGestureRecognizer()
            ..onLongPress = () {
              _showWordOptions(word);
            },
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: defaultStyle));
    }

    return TextSpan(children: spans);
  }

  void _showWordOptions(String word) async {
    final translation = await _translateWord(word); // <-- سيتم استدعاء دالة الترجمة الجديدة
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(word),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("الترجمة: $translation"),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: () => _speak(word), child: const Text("تشغيل الصوت")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: () => _speakSlow(word), child: const Text("تشغيل صوت بطيء")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: () => _addWordToDatabase(word), child: const Text("إضافة إلى كلمات الدرس")),
          ],
        ),
      ),
    );
  }

  Future<void> _addWordToDatabase(String word) async {
    await supabase.from('z_words_all').insert({
      'word': word,
      'level': widget.level,
      'lesson': widget.lesson,
      'is_add': 1
    });
    if (mounted) {
      Navigator.pop(context);
    }
  }

  // Future<void> _speak(String word) async {
  //   await tts.setSpeechRate(0.5);
  //   await tts.speak(word);
  // }
Future<void> _speak(String fullText) async {
  await tts.setSpeechRate(0.5);

  List<String> sentences = fullText.split(RegExp(r'(?<=[.!?])\s+'));

  for (int i = 0; i < sentences.length; i++) {
    String sentence = sentences[i].trim();
    if (sentence.isEmpty) continue;

    // التبديل بين صوت رجل وامرأة
    if (i % 2 == 0) {
      await tts.setVoice({'name': 'Microsoft Mark - English (United States)', 'locale': 'en-US'});
    } else {
      await tts.setVoice({'name': 'Microsoft Zira - English (United States)', 'locale': 'en-US'});
    }

    await tts.speak(sentence);
    await _waitForSpeechCompletion();
  }
}
Future<void> _speakSlow(String fullText) async {
  await tts.setSpeechRate(0.3);

  List<String> sentences = fullText.split(RegExp(r'(?<=[.!?])\s+'));

  for (int i = 0; i < sentences.length; i++) {
    String sentence = sentences[i].trim();
    if (sentence.isEmpty) continue;

    // التبديل بين صوت رجل وامرأة
    if (i % 2 == 0) {
      await tts.setVoice({'name': 'Microsoft Mark - English (United States)', 'locale': 'en-US'});
    } else {
      await tts.setVoice({'name': 'Microsoft Zira - English (United States)', 'locale': 'en-US'});
    }

    await tts.speak(sentence);
    await _waitForSpeechCompletion();
  }
}
Future<void> _waitForSpeechCompletion() async {
  bool isSpeaking = true;

  tts.setCompletionHandler(() {
    isSpeaking = false;
  });

  while (isSpeaking) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

Future<void> printAvailableVoices() async {
  var voices = await tts.getVoices;
  for (var voice in voices) {
    print(voice);
  }
}


  // Future<void> _speakSlow(String word) async {
  //   await tts.setSpeechRate(0.3);
  //   await tts.speak(word);
  // }
// هذا الكود متوافق فقط مع الإصدار القديم 1.0.0
Future<String> _translateWord(String word) async {
  // لاحظ أننا ننشئ كائنًا جديدًا من المترجم أولاً
  final translator = GoogleTranslator(); 

  try {
    var translation = await translator.translate(word, from: 'en', to: 'ar');
    return translation.text;
  } catch (e) {
    print("Translation Error: $e");
    return "فشل في الترجمة";
  }
}

}