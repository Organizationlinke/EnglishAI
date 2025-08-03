import 'package:flutter/material.dart';
import 'lessons_screen.dart';

class LevelsScreen extends StatelessWidget {
const LevelsScreen({super.key});
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('اختر المستوى')),
body: GridView.builder(
padding: const EdgeInsets.all(16),
gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
maxCrossAxisExtent: 150,
childAspectRatio: 3 / 2,
crossAxisSpacing: 12,
mainAxisSpacing: 12,
),
itemCount: 40,
itemBuilder: (context, index) {
final level = index + 1;
return Card(
child: InkWell(
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => LessonsScreen(level: level)),
);
},
child: Center(
child: Text(
'المستوى $level',
style:
const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
),
),
),
);
},
),
);
}
}

