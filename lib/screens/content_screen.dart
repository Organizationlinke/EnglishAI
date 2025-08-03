import 'package:flutter/material.dart';
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

@override
void initState() {
super.initState();
_contentFuture = _fetchContent();
}

Future<StoryContent> _fetchContent() async {
try {
// Fetch story, questions, and words in parallel for better performance
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

// Use the factory constructor in the model to parse the raw data
return StoryContent.fromRawSupabaseData(
storyData: storyData,
questionsData: questionsData,
wordsData: wordsData,
);
} catch (e) {
// Rethrow the error to be caught by the FutureBuilder
throw Exception('Failed to load content: $e');
}
}

@override
Widget build(BuildContext context) {
return FutureBuilder<StoryContent>(
future: _contentFuture,
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return Scaffold(
appBar: AppBar(),
body: const Center(child: CircularProgressIndicator()),
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
length: 3,
child: Scaffold(
appBar: AppBar(
title: Text(content.storyTitle),
bottom: const TabBar(
tabs: [
Tab(icon: Icon(Icons.menu_book), text: 'القصة'),
Tab(icon: Icon(Icons.edit), text: 'أسئلة كتابية'),
Tab(icon: Icon(Icons.check_circle_outline), text: 'أسئلة اختيارية'),
],
),
),
body: TabBarView(
children: [
// Tab 1: Story Content
SingleChildScrollView(
padding: const EdgeInsets.all(8.0),
child: Column(
children: [
_buildSectionCard(
context,
'القصة بالإنجليزي',
RichText(
text: _buildHighlightedText(
content.storyEn,
content.lessonWords,
Theme.of(context).textTheme.bodyLarge!,
),
textDirection: TextDirection.ltr,
),
),
_buildSectionCard(
context,
'الترجمة',
Text(content.storyAr,
style: Theme.of(context).textTheme.bodyLarge),
),
],
),
),

// Tab 2: Writing Questions
ListView.builder(
padding: const EdgeInsets.all(8.0),
itemCount: writingQuestions.length,
itemBuilder: (context, index) {
return WritingQuizCard(questionData: writingQuestions[index]);
},
),

// Tab 3: Multiple Choice Questions
ListView.builder(
padding: const EdgeInsets.all(8.0),
itemCount: mcqQuestions.length,
itemBuilder: (context, index) {
return MultipleChoiceQuizCard(questionData: mcqQuestions[index]);
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
Text(title,
style: Theme.of(context).textTheme.titleMedium?.copyWith(
fontWeight: FontWeight.bold,
color: Theme.of(context).primaryColor)),
const Divider(height: 20),
SizedBox(width: double.infinity, child: child),
],
),
),
);
}

TextSpan _buildHighlightedText(
String text, List<String> wordsToHighlight, TextStyle defaultStyle) {
final List<TextSpan> spans = [];
final highlightStyle = defaultStyle.copyWith(
color: Colors.blue.shade700, fontWeight: FontWeight.bold);
final String pattern = r'\b(' + wordsToHighlight.join('|') + r')\b';
final RegExp regex = RegExp(pattern, caseSensitive: false);
text.splitMapJoin(
regex,
onMatch: (Match match) {
spans.add(TextSpan(text: match[0], style: highlightStyle));
return '';
},
onNonMatch: (String nonMatch) {
spans.add(TextSpan(text: nonMatch, style: defaultStyle));
return '';
},
);
return TextSpan(children: spans);
}
}


