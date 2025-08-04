import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../main.dart'; // For instances
import '../utils/gemini_prompt.dart'; // For prompt builder
import 'content_screen.dart';

class StoriesScreen extends StatefulWidget {
  final int level;
  final int lesson;
  const StoriesScreen({super.key, required this.level, required this.lesson});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  late Future<List<Map<String, dynamic>>> _storiesFuture;
  bool _isGenerating = false;
  String _learnerLevel = 'A2';
  @override
  void initState() {
    super.initState();
    _storiesFuture = _fetchStories();
  }

  Future<List<Map<String, dynamic>>> _fetchStories() async {
    return await supabase
        .from('z_stories')
        .select('id, story_title')
        .eq('lesson', widget.lesson)
        .eq('level', widget.level);
  }

  void _refreshStories() {
    setState(() {
      _storiesFuture = _fetchStories();
    });
  }

  Future<void> _generateNewStory() async {
    if (geminiApiKey.isEmpty || geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      _showErrorDialog('مفتاح Gemini API غير موجود. يرجى إضافته.');
      return;
    }
    setState(() => _isGenerating = true);
    try {
      final wordsResponse = await supabase
          .from('rewords')
          .select('word')
          .eq('level', widget.level)
          .eq('current_lesson', widget.lesson);
      if (wordsResponse.isEmpty) {
        _showErrorDialog('لا توجد كلمات لهذا الدرس لإنشاء قصة.');
        setState(() => _isGenerating = false);
        return;
      }
      final words =
          (wordsResponse as List).map((e) => e['word'] as String).toList();
      final model =
          GenerativeModel(model: 'gemini-2.5-flash', apiKey: geminiApiKey);
      final prompt = buildGeminiPrompt(words, _learnerLevel);
      final content = [Content.text(prompt)];
      final response = await model.generateContent(
        content,
        generationConfig:
            GenerationConfig(responseMimeType: "application/json"),
      );
      final jsonText =
          response.text!.replaceAll(RegExp(r'```json|```'), '').trim();
      final generatedData = jsonDecode(jsonText);
      await _saveContentToSupabase(generatedData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم إنشاء وحفظ القصة الجديدة بنجاح! 🎉'),
              backgroundColor: Colors.green),
        );
      }
      _refreshStories();
    } catch (e) {
      _showErrorDialog('حدث خطأ أثناء إنشاء القصة: $e');
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _saveContentToSupabase(Map<String, dynamic> data) async {
    final storyInsert = await supabase
        .from('z_stories')
        .insert({
             // تم التعديل هنا
        'story_content': jsonEncode(data['story_content']), // نحول القائمة إلى نص JSON
        'story_title': data['story_title'],
        'lesson': widget.lesson,
        'level': widget.level
          // 'story_en': data['story_en'],
          // 'story_ar': data['story_ar'],
          // 'story_title': data['story_title'],
          // 'lesson': widget.lesson,
          // 'level':widget.level
        })
        .select()
        .single();
    final newStoryId = storyInsert['id'];
    final List<Map<String, dynamic>> allQuestions = [];
    (data['comprehension_questions'] as List).forEach((q) {
      allQuestions.add({
        'story_id': newStoryId,
        'qestion': q['question'],
        'choice1': q['options'][0],
        'choice2': q['options'][1],
        'choice3': q['options'][2],
        'choice4': q['options'][3],
        'choice_correct': q['answer']
      });
    });
    (data['vocabulary_questions'] as List).forEach((q) {
      allQuestions.add({
        'story_id': newStoryId,
        'qestion': q['question'],
        'choice1': q['options'][0],
        'choice2': q['options'][1],
        'choice3': q['options'][2],
        'choice4': q['options'][3],
        'choice_correct': q['answer']
      });
    });
    (data['comprehension_open_ended_questions'] as List).forEach((q) {
      allQuestions.add({
        'story_id': newStoryId,
        'qestion': 'open_ended:${q['question']}',
        'choice_correct': q['answer_key']
      });
    });
    (data['vocabulary_fill_in_the_blank_questions'] as List).forEach((q) {
      allQuestions.add({
        'story_id': newStoryId,
        'qestion': 'fill_in_the_blank:${q['word_ar']}',
        'choice_correct': q['word_en']
      });
    });
    await supabase.from('z_qestions').insert(allQuestions);
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حدث خطأ'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('حسناً')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('قصص الدرس ${widget.lesson}')),
      body: _isGenerating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('جاري إنشاء القصة، قد يستغرق الأمر بعض الوقت...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => _refreshStories(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('القصص الموجودة',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _storiesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('خطأ: ${snapshot.error}'));
                        }
                        final stories = snapshot.data!;
                        if (stories.isEmpty) {
                          return const Center(
                              child: Text('لا توجد قصص محفوظة لهذا الدرس.'));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stories.length,
                          itemBuilder: (context, index) {
                            final story = stories[index];
                            return Card(
                              child: ListTile(
                                title: Text(story['story_title']),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContentScreen(
                                      storyId: story['id'],
                                      level: widget.level,
                                      lesson: widget.lesson,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const Divider(height: 40, thickness: 1),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('إنشاء قصة جديدة بالذكاء الاصطناعي',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _learnerLevel,
                              decoration: InputDecoration(
                                labelText: 'مستوى المتعلم',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              items: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
                                  .map((level) {
                                return DropdownMenuItem(
                                    value: level, child: Text(level));
                              }).toList(),
                              onChanged: (value) {
                                if (value != null)
                                  setState(() => _learnerLevel = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _generateNewStory,
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text('أنشئ القصة الآن'),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
