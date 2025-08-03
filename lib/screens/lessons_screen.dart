import 'package:flutter/material.dart';
import '../main.dart'; // For supabase instance
import 'stories_screen.dart';

class LessonsScreen extends StatefulWidget {
final int level;
const LessonsScreen({super.key, required this.level});
@override
State<LessonsScreen> createState() => _LessonsScreenState();
}
class _LessonsScreenState extends State<LessonsScreen> {
late Future<List<int>> _lessonsFuture;
@override
void initState() {
super.initState();
_lessonsFuture = _fetchLessons();
}
Future<List<int>> _fetchLessons() async {
final response = await supabase
.from('z_words_all')
.select('lesson')
.eq('level', widget.level);
final lessons = (response as List)
.map<int>((item) => item['lesson'] as int)
.toSet()
.toList();
lessons.sort();
return lessons;
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text('دروس المستوى ${widget.level}')),
body: FutureBuilder<List<int>>(
future: _lessonsFuture,
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(child: CircularProgressIndicator());
}
if (snapshot.hasError) {
return Center(
child: Text('خطأ في تحميل الدروس: ${snapshot.error}'));
}
if (!snapshot.hasData || snapshot.data!.isEmpty) {
return const Center(
child: Text('لا توجد دروس متاحة في هذا المستوى.'));
}
final lessons = snapshot.data!;
return GridView.builder(
padding: const EdgeInsets.all(16),
gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
maxCrossAxisExtent: 150,
childAspectRatio: 3 / 2,
crossAxisSpacing: 12,
mainAxisSpacing: 12,
),
itemCount: lessons.length,
itemBuilder: (context, index) {
final lesson = lessons[index];
return Card(
child: InkWell(
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
StoriesScreen(level: widget.level, lesson: lesson),
),
);
},
child: Center(
child: Text(
'الدرس $lesson',
style: const TextStyle(
fontWeight: FontWeight.bold, fontSize: 16),
),
),
),
);
},
);
},
),
);
}
}

