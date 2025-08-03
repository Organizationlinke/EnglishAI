// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';

// // =================================================================
// // 1. تهيئة التطبيق ونقطة الدخول الرئيسية
// // =================================================================
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // تحميل متغيرات البيئة من ملف .env
//   // await dotenv.load(fileName: ".env");

//   // تهيئة Supabase
//   await Supabase.initialize(
//     url: 'https://qsvhdpitcljewzqjqhbe.supabase.co',
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFzdmhkcGl0Y2xqZXd6cWpxaGJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5NDYwMTksImV4cCI6MjA2OTUyMjAxOX0.YH-RR0w03qgYcpHQM-eygczVuheNljrbvXm6i-9uSwM',
//   );

//   runApp(const MyApp());
// }

// final supabase = Supabase.instance.client;
// final geminiApiKey = 'AIzaSyDQ9_0_qyzzqDO1Sq5ngL0VGxTfAUjTOVI';

// // =================================================================
// // 2. التطبيق الرئيسي والثيم والألوان
// // =================================================================
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     const Color primaryColor = Color(0xFF3B82F6);
//     const Color backgroundColor = Color(0xFFF0F4F8);

//     return MaterialApp(
//       title: 'رحلة تعلم المفردات',
//       theme: ThemeData(
//         primaryColor: primaryColor,
//         scaffoldBackgroundColor: backgroundColor,
//         textTheme: GoogleFonts.cairoTextTheme(textTheme),
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.white,
//           elevation: 1,
//           centerTitle: true,
//           iconTheme: IconThemeData(color: Colors.black87),
//           titleTextStyle: TextStyle(
//             fontFamily: 'Cairo',
//             color: primaryColor,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: primaryColor,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
//             textStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
//           ),
//         ),
//         cardTheme: CardTheme(
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           margin: const EdgeInsets.symmetric(vertical: 6),
//         ),
//         colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
//         useMaterial3: true,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: const LevelsScreen(),
//       builder: (context, child) {
//         // تحديد اتجاه النص ليكون من اليمين لليسار
//         return Directionality(
//           textDirection: TextDirection.rtl,
//           child: child!,
//         );
//       },
//     );
//   }
// }

// // =================================================================
// // 3. شاشة المستويات (LevelsScreen)
// // =================================================================
// class LevelsScreen extends StatelessWidget {
//   const LevelsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('اختر المستوى')),
//       body: GridView.builder(
//         padding: const EdgeInsets.all(16),
//         gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//           maxCrossAxisExtent: 150,
//           childAspectRatio: 3 / 2,
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//         ),
//         itemCount: 40,
//         itemBuilder: (context, index) {
//           final level = index + 1;
//           return Card(
//             elevation: 2,
//             child: InkWell(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => LessonsScreen(level: level)),
//                 );
//               },
//               child: Center(
//                 child: Text(
//                   'المستوى $level',
//                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // =================================================================
// // 4. شاشة الدروس (LessonsScreen)
// // =================================================================
// class LessonsScreen extends StatefulWidget {
//   final int level;
//   const LessonsScreen({super.key, required this.level});

//   @override
//   State<LessonsScreen> createState() => _LessonsScreenState();
// }

// class _LessonsScreenState extends State<LessonsScreen> {
//   late Future<List<int>> _lessonsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _lessonsFuture = _fetchLessons();
//   }

//   Future<List<int>> _fetchLessons() async {
//     final response = await supabase
//         .from('z_words_all')
//         .select('lesson')
//         .eq('level', widget.level);

//     final lessons = (response as List)
//         .map<int>((item) => item['lesson'] as int)
//         .toSet()
//         .toList();
//     lessons.sort();
//     return lessons;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('دروس المستوى ${widget.level}')),
//       body: FutureBuilder<List<int>>(
//         future: _lessonsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('خطأ في تحميل الدروس: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('لا توجد دروس متاحة في هذا المستوى.'));
//           }

//           final lessons = snapshot.data!;
//           return GridView.builder(
//             padding: const EdgeInsets.all(16),
//             gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//               maxCrossAxisExtent: 150,
//               childAspectRatio: 3 / 2,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//             ),
//             itemCount: lessons.length,
//             itemBuilder: (context, index) {
//               final lesson = lessons[index];
//               return Card(
//                 elevation: 2,
//                 child: InkWell(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => StoriesScreen(level: widget.level, lesson: lesson),
//                       ),
//                     );
//                   },
//                   child: Center(
//                     child: Text(
//                       'الدرس $lesson',
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// // =================================================================
// // 5. شاشة القصص (StoriesScreen) - لعرض القصص الموجودة وإنشاء جديد
// // =================================================================
// class StoriesScreen extends StatefulWidget {
//   final int level;
//   final int lesson;
//   const StoriesScreen({super.key, required this.level, required this.lesson});

//   @override
//   State<StoriesScreen> createState() => _StoriesScreenState();
// }

// class _StoriesScreenState extends State<StoriesScreen> {
//   late Future<List<Map<String, dynamic>>> _storiesFuture;
//   bool _isGenerating = false;
//   String _learnerLevel = 'A2';

//   @override
//   void initState() {
//     super.initState();
//     _storiesFuture = _fetchStories();
//   }

//   Future<List<Map<String, dynamic>>> _fetchStories() async {
//     return await supabase
//         .from('z_stories')
//         .select('id, story_title')
//         .eq('lesson', widget.lesson);
//   }
  
//   void _refreshStories() {
//       setState(() {
//         _storiesFuture = _fetchStories();
//       });
//   }


//   Future<void> _generateNewStory() async {
//     if (geminiApiKey == null || geminiApiKey!.isEmpty || geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
//       _showErrorDialog('مفتاح Gemini API غير موجود. يرجى إضافته في ملف .env');
//       return;
//     }

//     setState(() => _isGenerating = true);

//     try {
//         // 1. جلب الكلمات
//         final wordsResponse = await supabase
//             .from('z_words_all')
//             .select('word')
//             .eq('level', widget.level)
//             .eq('lesson', widget.lesson);

//         if (wordsResponse.isEmpty) {
//             _showErrorDialog('لا توجد كلمات لهذا الدرس لإنشاء قصة.');
//             setState(() => _isGenerating = false);
//             return;
//         }
//         final words = (wordsResponse as List).map((e) => e['word'] as String).toList();
        
//         // 2. إعداد Gemini
//         final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiApiKey!);
//         final prompt = _buildGeminiPrompt(words, _learnerLevel);
//         final content = [Content.text(prompt)];
        
//         // 3. إنشاء المحتوى
//         final response = await model.generateContent(
//             content,
//             generationConfig: GenerationConfig(responseMimeType: "application/json"),
//         );
        
//         // 4. معالجة وحفظ المحتوى
//         final jsonText = response.text!.replaceAll(RegExp(r'```json|```'), '').trim();
//         final generatedData = jsonDecode(jsonText);
        
//         await _saveContentToSupabase(generatedData);
        
//         ScaffoldMessenger.of(context).showSnackBar(
//            const SnackBar(content: Text('تم إنشاء وحفظ القصة الجديدة بنجاح! 🎉'), backgroundColor: Colors.green),
//         );
//         _refreshStories();

//     } catch (e) {
//         _showErrorDialog('حدث خطأ أثناء إنشاء القصة: $e');
//     } finally {
//         setState(() => _isGenerating = false);
//     }
// }


//   Future<void> _saveContentToSupabase(Map<String, dynamic> data) async {
//     // حفظ القصة
//     final storyInsert = await supabase.from('z_stories').insert({
//       'story_en': data['story_en'],
//       'story_ar': data['story_ar'],
//       'story_title': data['story_title'],
//       'lesson': widget.lesson
//     }).select().single();

//     final newStoryId = storyInsert['id'];

//     // تجميع كل الأسئلة
//     final List<Map<String, dynamic>> allQuestions = [];

//     // أسئلة الاستيعاب
//     (data['comprehension_questions'] as List).forEach((q) {
//         allQuestions.add({
//             'story_id': newStoryId,
//             'qestion': q['question'],
//             'choice1': q['options'][0], 'choice2': q['options'][1],
//             'choice3': q['options'][2], 'choice4': q['options'][3],
//             'choice_correct': q['answer']
//         });
//     });

//     // أسئلة المفردات
//     (data['vocabulary_questions'] as List).forEach((q) {
//         allQuestions.add({
//             'story_id': newStoryId,
//             'qestion': q['question'],
//             'choice1': q['options'][0], 'choice2': q['options'][1],
//             'choice3': q['options'][2], 'choice4': q['options'][3],
//             'choice_correct': q['answer']
//         });
//     });

//     // أسئلة مفتوحة
//     (data['comprehension_open_ended_questions'] as List).forEach((q) {
//         allQuestions.add({
//             'story_id': newStoryId,
//             'qestion': 'open_ended:${q['question']}',
//             'choice_correct': q['answer_key']
//         });
//     });
    
//     // أسئلة ملء الفراغ
//      (data['vocabulary_fill_in_the_blank_questions'] as List).forEach((q) {
//         allQuestions.add({
//             'story_id': newStoryId,
//             'qestion': 'fill_in_the_blank:${q['word_ar']}',
//             'choice_correct': q['word_en']
//         });
//     });

//     // حفظ كل الأسئلة دفعة واحدة
//     await supabase.from('z_qestions').insert(allQuestions);
//   }


//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('حدث خطأ'),
//         content: Text(message),
//         actions: [
//           TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('حسناً')),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('قصص الدرس ${widget.lesson}')),
//       body: _isGenerating
//           ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 20),
//                   Text('جاري إنشاء القصة، قد يستغرق الأمر بعض الوقت...'),
//                 ],
//               ),
//             )
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('القصص الموجودة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 10),
//                   FutureBuilder<List<Map<String, dynamic>>>(
//                     future: _storiesFuture,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       if (snapshot.hasError) {
//                         return Center(child: Text('خطأ: ${snapshot.error}'));
//                       }
//                       final stories = snapshot.data!;
//                       if (stories.isEmpty) {
//                         return const Center(child: Text('لا توجد قصص محفوظة لهذا الدرس.'));
//                       }
//                       return ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: stories.length,
//                         itemBuilder: (context, index) {
//                           final story = stories[index];
//                           return Card(
//                             child: ListTile(
//                               title: Text(story['story_title']),
//                               trailing: const Icon(Icons.arrow_forward_ios),
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => ContentScreen(
//                                       storyId: story['id'],
//                                       level: widget.level,
//                                       lesson: widget.lesson,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                   const Divider(height: 40, thickness: 1),
//                   Card(
//                      color: Colors.white,
//                      child: Padding(
//                        padding: const EdgeInsets.all(16.0),
//                        child: Column(
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          children: [
//                             const Text(
//                                'إنشاء قصة جديدة بالذكاء الاصطناعي',
//                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 16),
//                             DropdownButtonFormField<String>(
//                                value: _learnerLevel,
//                                decoration: InputDecoration(
//                                    labelText: 'مستوى المتعلم',
//                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                                ),
//                                items: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map((level) {
//                                   return DropdownMenuItem(value: level, child: Text(level));
//                                }).toList(),
//                                onChanged: (value) {
//                                    if (value != null) setState(() => _learnerLevel = value);
//                                },
//                             ),
//                             const SizedBox(height: 16),
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton.icon(
//                                   onPressed: _generateNewStory,
//                                   icon: const Icon(Icons.auto_awesome),
//                                   label: const Text('أنشئ القصة الآن'),
//                               ),
//                             )
//                          ],
//                        ),
//                      ),
//                   )
//                 ],
//               ),
//             ),
//     );
//   }
// }


// // =================================================================
// // 6. شاشة المحتوى (ContentScreen) - لعرض القصة والأسئلة
// // =================================================================
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
//   late Future<Map<String, dynamic>> _contentFuture;

//   @override
//   void initState() {
//     super.initState();
//     _contentFuture = _fetchContent();
//   }

//   Future<Map<String, dynamic>> _fetchContent() async {
//     // Fetch story, questions, and words in parallel
//     // final results = await Future.wait([
//     //   supabase.from('z_stories').select().eq('id', widget.storyId).single(),
//     //   supabase.from('z_qestions').select().eq('story_id', widget.storyId),
//     //   supabase
//     //       .from('z_words_all')
//     //       .select('word')
//     //       .eq('level', widget.level)
//     //       .eq('lesson', widget.lesson),
//     // ]);
// final results = await Future.wait<dynamic>([ // <--- ✨ تم التعديل هنا
//       supabase.from('z_stories').select().eq('id', widget.storyId).single(),
//       supabase.from('z_qestions').select().eq('story_id', widget.storyId),
//       supabase
//           .from('z_words_all')
//           .select('word')
//           .eq('level', widget.level)
//           .eq('lesson', widget.lesson),
//     ]);
//     final storyData = results[0] as Map<String, dynamic>;
//     final questionsData = results[1] as List<dynamic>;
//     final wordsData = results[2] as List<dynamic>;

//     final lessonWords = wordsData.map((e) => e['word'].toString()).toList();

//     // Process questions
//     final structuredData = {
//         'story_title': storyData['story_title'],
//         'story_en': storyData['story_en'],
//         'story_ar': storyData['story_ar'],
//         'lesson_words': lessonWords,
//         'comprehension_questions': <Map<String, dynamic>>[],
//         'vocabulary_questions': <Map<String, dynamic>>[],
//     };

//     for (var q in questionsData) {
//         final questionText = q['qestion'] as String;
//         if (questionText.startsWith('open_ended:') || questionText.startsWith('fill_in_the_blank:')) {
//             // Not handling these types in this simplified UI for now
//         } else {
//             final questionMap = {
//                 'question': questionText,
//                 'options': [q['choice1'], q['choice2'], q['choice3'], q['choice4']].where((c) => c != null).toList().cast<String>(),
//                 'answer': q['choice_correct']
//             };

//             if (questionText.contains('What does the word')) {
//                 structuredData['vocabulary_questions']!.add(questionMap);
//             } else {
//                 structuredData['comprehension_questions']!.add(questionMap);
//             }
//         }
//     }
//     return structuredData;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('المحتوى التعليمي')),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _contentFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('خطأ: ${snapshot.error}'));
//           }
//           final content = snapshot.data!;

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(content['story_title'], style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 16),
                
//                 // Story Section with highlighted words
//                 _buildSectionCard(
//                     context, 'القصة بالإنجليزي', 
//                     RichText(
//                         text: _buildHighlightedText(
//                             content['story_en'], 
//                             List<String>.from(content['lesson_words']),
//                             Theme.of(context).textTheme.bodyLarge!,
//                         ),
//                         textDirection: TextDirection.ltr,
//                     )
//                 ),
//                 _buildSectionCard(
//                     context, 'الترجمة', 
//                     Text(content['story_ar'], style: Theme.of(context).textTheme.bodyLarge)
//                 ),

//                 // Comprehension Questions
//                 if (content['comprehension_questions'].isNotEmpty) ...[
//                     const SizedBox(height: 20),
//                     Text('أسئلة استيعاب', style: Theme.of(context).textTheme.titleLarge),
//                     const SizedBox(height: 10),
//                     ...content['comprehension_questions'].map((q) => QuizItemWidget(question: q)).toList(),
//                 ],

//                 // Vocabulary Questions
//                 if (content['vocabulary_questions'].isNotEmpty) ...[
//                     const SizedBox(height: 20),
//                     Text('أسئلة مفردات', style: Theme.of(context).textTheme.titleLarge),
//                     const SizedBox(height: 10),
//                     ...content['vocabulary_questions'].map((q) => QuizItemWidget(question: q)).toList(),
//                 ]
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Card _buildSectionCard(BuildContext context, String title, Widget child) {
//     return Card(
//         color: Colors.white,
//         child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                     Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
//                     const Divider(height: 20),
//                     SizedBox(width: double.infinity, child: child),
//                 ],
//             ),
//         ),
//     );
//   }
  
//   // *** الدالة الأساسية لتمييز الكلمات ***
//   TextSpan _buildHighlightedText(String text, List<String> wordsToHighlight, TextStyle defaultStyle) {
//     final List<TextSpan> spans = [];
//     final highlightStyle = defaultStyle.copyWith(color: Colors.blue.shade700, fontWeight: FontWeight.bold);

//     // إنشاء تعبير نمطي (RegExp) للبحث عن الكلمات مع تجاهل حالة الأحرف
//     // ويضمن البحث عن الكلمات الكاملة فقط (باستخدام \b)
//     final String pattern = r'\b(' + wordsToHighlight.join('|') + r')\b';
//     final RegExp regex = RegExp(pattern, caseSensitive: false);

//     text.splitMapJoin(
//       regex,
//       onMatch: (Match match) {
//         spans.add(TextSpan(text: match[0], style: highlightStyle));
//         return '';
//       },
//       onNonMatch: (String nonMatch) {
//         spans.add(TextSpan(text: nonMatch, style: defaultStyle));
//         return '';
//       },
//     );

//     return TextSpan(children: spans);
//   }
// }

// // =================================================================
// // 7. ويدجت لعرض عنصر الاختبار (QuizItemWidget)
// // =================================================================
// class QuizItemWidget extends StatefulWidget {
//   final Map<String, dynamic> question;
//   const QuizItemWidget({super.key, required this.question});

//   @override
//   State<QuizItemWidget> createState() => _QuizItemWidgetState();
// }

// class _QuizItemWidgetState extends State<QuizItemWidget> {
//   String? _selectedOption;
//   bool _answered = false;

//   void _checkAnswer(String option) {
//     setState(() {
//       _selectedOption = option;
//       _answered = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<String> options = List<String>.from(widget.question['options'])..shuffle();
//     final String correctAnswer = widget.question['answer'];

//     return Card(
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.question['question'],
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 12),
//             ...options.map((option) {
//               Color? tileColor;
//               Color? borderColor;

//               if (_answered) {
//                 if (option == correctAnswer) {
//                   tileColor = Colors.green.shade50;
//                   borderColor = Colors.green.shade400;
//                 } else if (option == _selectedOption) {
//                   tileColor = Colors.red.shade50;
//                   borderColor = Colors.red.shade400;
//                 }
//               }

//               return Container(
//                 margin: const EdgeInsets.symmetric(vertical: 4),
//                 decoration: BoxDecoration(
//                   color: tileColor,
//                   border: Border.all(color: borderColor ?? Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: ListTile(
//                   title: Text(option),
//                   onTap: _answered ? null : () => _checkAnswer(option),
//                 ),
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }
// }


// // =================================================================
// // 8. Prompt for Gemini API
// // =================================================================
// String _buildGeminiPrompt(List<String> words, String userLevel) {
//   return """
// You are an expert English teacher creating learning materials for an Arabic-speaking student.
// The student's proficiency level is $userLevel.
// The vocabulary words for this lesson are: ${words.join(', ')}.

// Your task is to generate a comprehensive learning module. Your response MUST be a single, valid JSON object and nothing else. Do not include any text, notes, or markdown formatting.

// The JSON object must have the following structure:
// {
//     "story_title": "A concise and creative English title for the story, followed by '- level$userLevel'. For example: 'A Day at the Park - levelA2'.",
//     "story_en": "A short, engaging story in English, suitable for the $userLevel level, that naturally uses ALL of the provided vocabulary words. The story should be interesting and make sense.",
//     "story_ar": "An accurate and natural-sounding Arabic translation of the English story.",
//     "comprehension_questions": [
//         {
//             "question": "A multiple-choice question in English about the story's plot, characters, or details.",
//             "options": ["An English option", "Another English option", "A third English option", "The correct English option"],
//             "answer": "The text of the correct English option."
//         }
//     ],
//     "vocabulary_questions": [
//         {
//             "word": "The English word from the list",
//             "question": "What does the word '[the English word]' mean?",
//             "options": ["A plausible but incorrect Arabic meaning", "The correct Arabic meaning", "Another incorrect Arabic meaning", "A third incorrect Arabic meaning"],
//             "answer": "The correct Arabic meaning."
//         }
//     ],
//     "comprehension_open_ended_questions": [
//         {
//             "question": "An open-ended question in English about the story's plot, characters, or themes.",
//             "answer_key": "A sample correct answer in English."
//         }
//     ],
//     "vocabulary_fill_in_the_blank_questions": [
//         {
//             "word_ar": "The Arabic meaning of a word from the list.",
//             "word_en": "The correct English word."
//         }
//     ]
// }

// Please adhere to these rules:
// 1.  The "story_en" must include every single word from the vocabulary list.
// 2.  Generate exactly 5 "comprehension_questions".
// 3.  Generate exactly one "vocabulary_question" for EACH word in the provided vocabulary list.
// 4.  For "vocabulary_questions", the "options" must be in Arabic. Ensure the options are shuffled so the correct answer isn't always in the same position.
// 5.  Generate exactly 3 "comprehension_open_ended_questions".
// 6.  Generate exactly one "vocabulary_fill_in_the_blank_questions" for EACH word.
// """;
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/levels_screen.dart';

Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();

// تهيئة Supabase
await Supabase.initialize(
url: 'https://qsvhdpitcljewzqjqhbe.supabase.co',
anonKey:
'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFzdmhkcGl0Y2xqZXd6cWpxaGJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5NDYwMTksImV4cCI6MjA2OTUyMjAxOX0.YH-RR0w03qgYcpHQM-eygczVuheNljrbvXm6i-9uSwM',
);

runApp(const MyApp());
}

// للوصول السهل في أي مكان بالتطبيق
final supabase = Supabase.instance.client;
// ⚠️ تحذير أمني: لا تضع مفتاح API هنا في تطبيق حقيقي
// انقله إلى متغيرات البيئة
const geminiApiKey = 'AIzaSyDQ9_0_qyzzqDO1Sq5ngL0VGxTfAUjTOVI';

class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
final textTheme = Theme.of(context).textTheme;
const Color primaryColor = Color(0xFF3B82F6);
const Color backgroundColor = Color(0xFFF0F4F8);

return MaterialApp(
title: 'رحلة تعلم المفردات',
theme: ThemeData(
primaryColor: primaryColor,
scaffoldBackgroundColor: backgroundColor,
textTheme: GoogleFonts.cairoTextTheme(textTheme),
appBarTheme: const AppBarTheme(
backgroundColor: Colors.white,
elevation: 1,
centerTitle: true,
iconTheme: IconThemeData(color: Colors.black87),
titleTextStyle: TextStyle(
fontFamily: 'Cairo',
color: primaryColor,
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
elevatedButtonTheme: ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(
backgroundColor: primaryColor,
foregroundColor: Colors.white,
shape:
RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
padding:
const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
textStyle: const TextStyle(
fontFamily: 'Cairo', fontWeight: FontWeight.bold),
),
),
cardTheme: CardTheme(
elevation: 2,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
color: Colors.white,
),
 tabBarTheme: const TabBarTheme(
 labelColor: primaryColor,
 unselectedLabelColor: Colors.black54,
 indicatorColor: primaryColor,
 indicatorSize: TabBarIndicatorSize.tab,
 ),
colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
useMaterial3: true,
),
debugShowCheckedModeBanner: false,
home: const LevelsScreen(),
builder: (context, child) {
return Directionality(
textDirection: TextDirection.rtl,
child: child!,
);
},
);
}
}


