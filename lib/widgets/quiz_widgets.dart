// import 'package:flutter/material.dart';
// import '../models/story_content_model.dart';

// // --- Widget for Multiple Choice Questions ---
// class MultipleChoiceQuizCard extends StatefulWidget {
//   final dynamic questionData;
//   const MultipleChoiceQuizCard({super.key, required this.questionData});

//   @override
//   State<MultipleChoiceQuizCard> createState() => _MultipleChoiceQuizCardState();
// }

// class _MultipleChoiceQuizCardState extends State<MultipleChoiceQuizCard> {
//   String? _selectedOption;
//   bool _answered = false;
//   late List<String> _shuffledOptions;

//   @override
//   void initState() {
//     super.initState();
// // Shuffle options once and store them
//     _shuffledOptions = List<String>.from(widget.questionData.options)
//       ..shuffle();
//   }

//   void _checkAnswer(String option) {
//     setState(() {
//       _selectedOption = option;
//       _answered = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String questionText = widget.questionData.question;
//     final String correctAnswer = widget.questionData.answer;

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               questionText,
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 12),
//             ..._shuffledOptions.map((option) {
//               Color? tileColor;
//               Color? borderColor;

//               if (_answered) {
//                 if (option == correctAnswer) {
//                   tileColor = Colors.green.shade50;
//                   borderColor = Colors.green;
//                 } else if (option == _selectedOption) {
//                   tileColor = Colors.red.shade50;
//                   borderColor = Colors.red;
//                 }
//               }

//               return Container(
//                 margin: const EdgeInsets.symmetric(vertical: 4),
//                 decoration: BoxDecoration(
//                   color: tileColor,
//                   border:
//                       Border.all(color: borderColor ?? Colors.grey.shade300),
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

// // --- Widget for Writing-based Questions ---
// class WritingQuizCard extends StatefulWidget {
//   final dynamic questionData;
//   const WritingQuizCard({Key? key, required this.questionData})
//       : super(key: key);
//   @override
//   State<WritingQuizCard> createState() => _WritingQuizCardState();
// }

// class _WritingQuizCardState extends State<WritingQuizCard> {
//   final TextEditingController _controller = TextEditingController();
//   bool _showAnswer = false;
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     String questionText = '';
//     String correctAnswer = '';

//     if (widget.questionData is OpenEndedQuestion) {
//       questionText = widget.questionData.question;
//       correctAnswer = widget.questionData.answerKey;
//     } else if (widget.questionData is FillInTheBlankQuestion) {
//       questionText =
//           'اكتب المعنى الإنجليزي لكلمة: "${widget.questionData.wordAr}"';
//       correctAnswer = widget.questionData.wordEn;
//     }

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               questionText,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _controller,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: 'اكتب إجابتك هنا...',
//               ),
//               textDirection: TextDirection.ltr,
//               textAlign: TextAlign.left,
//             ),
//             const SizedBox(height: 12),
//             if (_showAnswer)
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                     color: Colors.green.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.green)),
//                 child: Text(
//                   'الإجابة النموذجية: $correctAnswer',
//                   style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.green.shade900,
//                       fontWeight: FontWeight.bold),
//                   textDirection: TextDirection.ltr,
//                   textAlign: TextAlign.left,
//                 ),
//               ),
//             const SizedBox(height: 8),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _showAnswer = !_showAnswer;
//                   });
//                 },
//                 child: Text(_showAnswer ? 'إخفاء الإجابة' : 'إظهار الإجابة'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../models/story_content_model.dart';

// --- Widget for Multiple Choice Questions ---
class MultipleChoiceQuizCard extends StatefulWidget {
  final dynamic questionData;
  const MultipleChoiceQuizCard({super.key, required this.questionData});

  @override
  State<MultipleChoiceQuizCard> createState() => _MultipleChoiceQuizCardState();
}

class _MultipleChoiceQuizCardState extends State<MultipleChoiceQuizCard> {
  String? _selectedOption;
  bool _answered = false;
  late List<String> _shuffledOptions;

  @override
  void initState() {
    super.initState();
    // Shuffle options once and store them
    _shuffledOptions = List<String>.from(widget.questionData.options)
      ..shuffle();
  }

  void _checkAnswer(String option) {
    setState(() {
      _selectedOption = option;
      _answered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String questionText = widget.questionData.question;
    final String correctAnswer = widget.questionData.answer;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ..._shuffledOptions.map((option) {
              Color? tileColor;
              Color? borderColor;

              if (_answered) {
                if (option == correctAnswer) {
                  tileColor = Colors.green.shade50;
                  borderColor = Colors.green;
                } else if (option == _selectedOption) {
                  tileColor = Colors.red.shade50;
                  borderColor = Colors.red;
                }
              }

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: tileColor,
                  border: Border.all(color: borderColor ?? Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(option),
                  onTap: _answered ? null : () => _checkAnswer(option),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// --- Widget for Writing-based Questions ---
class WritingQuizCard extends StatefulWidget {
  final dynamic questionData;
  const WritingQuizCard({Key? key, required this.questionData})
      : super(key: key);
  @override
  State<WritingQuizCard> createState() => _WritingQuizCardState();
}

class _WritingQuizCardState extends State<WritingQuizCard> {
  final TextEditingController _controller = TextEditingController();
  bool _showAnswer = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String questionText = '';
    String correctAnswer = '';

    if (widget.questionData is OpenEndedQuestion) {
      questionText = widget.questionData.question;
      correctAnswer = widget.questionData.answerKey;
    } else if (widget.questionData is FillInTheBlankQuestion) {
      questionText =
          'اكتب المعنى الإنجليزي لكلمة: "${widget.questionData.wordAr}"';
      correctAnswer = widget.questionData.wordEn;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'اكتب إجابتك هنا...',
              ),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            if (_showAnswer)
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green)),
                child: Text(
                  'الإجابة النموذجية: $correctAnswer',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold),
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAnswer = !_showAnswer;
                  });
                },
                child: Text(_showAnswer ? 'إخفاء الإجابة' : 'إظهار الإجابة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
