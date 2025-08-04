
// import 'dart:convert'; // استيراد للمساعدة في التحويل
// // أضف هذا الكلاس في بداية الملف
// class SentencePair {
//   final String en;
//   final String ar;
//   SentencePair({required this.en, required this.ar});

//   factory SentencePair.fromJson(Map<String, dynamic> json) {
//     return SentencePair(
//       en: json['en'] ?? '',
//       ar: json['ar'] ?? '',
//     );
//   }
// }

// class StoryContent {
//   final String storyTitle;
//   // تم التعديل هنا
//   final List<SentencePair> storyContent;
//   final List<String> lessonWords;
//   final List<ComprehensionQuestion> comprehensionQuestions;
//   final List<VocabularyQuestion> vocabularyQuestions;
//   final List<OpenEndedQuestion> comprehensionOpenEndedQuestions;
//   final List<FillInTheBlankQuestion> vocabularyFillInTheBlankQuestions;

//   StoryContent({
//     required this.storyTitle,
//     // تم التعديل هنا
//     required this.storyContent,
//     required this.lessonWords,
//     required this.comprehensionQuestions,
//     required this.vocabularyQuestions,
//     required this.comprehensionOpenEndedQuestions,
//     required this.vocabularyFillInTheBlankQuestions,
//   });

//   // helper getters to get the full story text if needed
//   String get storyEn => storyContent.map((s) => s.en).join(' ');
//   String get storyAr => storyContent.map((s) => s.ar).join(' ');


//   /// Factory constructor to parse raw Supabase data into a structured model
//   factory StoryContent.fromRawSupabaseData({
//     required Map<String, dynamic> storyData,
//     required List<dynamic> questionsData,
//     required List<dynamic> wordsData,
//   }) {
//     // ... الكود الخاص بالأسئلة يبقى كما هو ...
//     final List<ComprehensionQuestion> compQuestions = [];
//     final List<VocabularyQuestion> vocabQuestions = [];
//     final List<OpenEndedQuestion> openEndedQuestions = [];
//     final List<FillInTheBlankQuestion> fillBlankQuestions = [];
//     for (var q in questionsData) {
//       // ... نفس اللوجيك بدون تغيير
//     }

//     // --- تعديل منطق استخلاص القصة ---
//     List<SentencePair> parsedStoryContent = [];
//     // Supabase قد يخزن الـ JSON كنص، لذا نحتاج لفك ترميزه
//     if (storyData['story_content'] != null) {
//       // story_content هو اسم العمود الجديد في قاعدة البيانات
//       final contentList = jsonDecode(storyData['story_content'] as String) as List<dynamic>;
//       parsedStoryContent = contentList
//           .map((item) => SentencePair.fromJson(item as Map<String, dynamic>))
//           .toList();
//     }

//     return StoryContent(
//       storyTitle: storyData['story_title'] ?? 'بدون عنوان',
//       storyContent: parsedStoryContent, // تم التعديل هنا
//       lessonWords: wordsData.map((e) => e['word'].toString()).toList(),
//       comprehensionQuestions: compQuestions,
//       vocabularyQuestions: vocabQuestions,
//       comprehensionOpenEndedQuestions: openEndedQuestions,
//       vocabularyFillInTheBlankQuestions: fillBlankQuestions,
//     );
//   }
// }

// // 2. Multiple Choice - Comprehension
// class ComprehensionQuestion {
// final String question;
// final List<String> options;
// final String answer;
// ComprehensionQuestion({required this.question, required this.options, required this.answer});
// }

// // 3. Multiple Choice - Vocabulary
// class VocabularyQuestion {
// final String word;
// final String question;
// final List<String> options;
// final String answer;
// VocabularyQuestion({required this.word, required this.question, required this.options, required this.answer});
// }

// // 4. Open Ended (Writing) - Comprehension
// class OpenEndedQuestion {
// final String question;
// final String answerKey;
// OpenEndedQuestion({required this.question, required this.answerKey});
// }

// // 5. Fill in the Blank (Writing) - Vocabulary
// class FillInTheBlankQuestion {
// final String wordAr;
// final String wordEn;
// FillInTheBlankQuestion({required this.wordAr, required this.wordEn});
// }


import 'dart:convert';

// Class to hold a pair of sentences (English and Arabic)
class SentencePair {
  final String en;
  final String ar;
  SentencePair({required this.en, required this.ar});

  factory SentencePair.fromJson(Map<String, dynamic> json) {
    return SentencePair(
      en: json['en'] ?? '',
      ar: json['ar'] ?? '',
    );
  }
}

// 1. The main container for all content
class StoryContent {
  final String storyTitle;
  final List<SentencePair> storyContent;
  final List<String> lessonWords;
  final List<ComprehensionQuestion> comprehensionQuestions;
  final List<VocabularyQuestion> vocabularyQuestions;
  final List<OpenEndedQuestion> comprehensionOpenEndedQuestions;
  final List<FillInTheBlankQuestion> vocabularyFillInTheBlankQuestions;

  StoryContent({
    required this.storyTitle,
    required this.storyContent,
    required this.lessonWords,
    required this.comprehensionQuestions,
    required this.vocabularyQuestions,
    required this.comprehensionOpenEndedQuestions,
    required this.vocabularyFillInTheBlankQuestions,
  });

  // helper getters to get the full story text if needed
  String get storyEn => storyContent.map((s) => s.en).join(' ');
  String get storyAr => storyContent.map((s) => s.ar).join(' ');

  /// Factory constructor to parse raw Supabase data into a structured model
  factory StoryContent.fromRawSupabaseData({
    required Map<String, dynamic> storyData,
    required List<dynamic> questionsData,
    required List<dynamic> wordsData,
  }) {
    final List<ComprehensionQuestion> compQuestions = [];
    final List<VocabularyQuestion> vocabQuestions = [];
    final List<OpenEndedQuestion> openEndedQuestions = [];
    final List<FillInTheBlankQuestion> fillBlankQuestions = [];

    // --- THIS IS THE FIXED PART ---
    // Loop through the questions data and parse each one
    for (var q in questionsData) {
      // Safely cast the question text
      final questionText = q['qestion'] as String?;
      if (questionText == null || questionText.isEmpty) {
        continue; // Skip if the question text is null or empty
      }

      // Check for Open-Ended questions
      if (questionText.startsWith('open_ended:')) {
        openEndedQuestions.add(OpenEndedQuestion(
          question: questionText.replaceFirst('open_ended:', '').trim(),
          answerKey: q['choice_correct'] ?? '',
        ));
      
      // Check for Fill-in-the-Blank questions
      } else if (questionText.startsWith('fill_in_the_blank:')) {
        fillBlankQuestions.add(FillInTheBlankQuestion(
          wordAr: questionText.replaceFirst('fill_in_the_blank:', '').trim(),
          wordEn: q['choice_correct'] ?? '',
        ));

      // Handle Multiple Choice questions
      } else {
        final options = [
          q['choice1'],
          q['choice2'],
          q['choice3'],
          q['choice4']
        ].where((c) => c != null).toList().cast<String>();

        // Differentiate between Vocabulary and Comprehension MCQs
        if (questionText.contains('What does the word')) {
          final wordMatch = RegExp(r"\[(.*?)\]").firstMatch(questionText);
          vocabQuestions.add(VocabularyQuestion(
            word: wordMatch?.group(1) ?? '',
            question: questionText,
            options: options,
            answer: q['choice_correct'] ?? '',
          ));
        } else {
          compQuestions.add(ComprehensionQuestion(
            question: questionText,
            options: options,
            answer: q['choice_correct'] ?? '',
          ));
        }
      }
    }
    // --- END OF FIX ---

    // Parse story content from JSON string
    List<SentencePair> parsedStoryContent = [];
    if (storyData['story_content'] != null) {
      final contentList =
          jsonDecode(storyData['story_content'] as String) as List<dynamic>;
      parsedStoryContent = contentList
          .map((item) => SentencePair.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return StoryContent(
      storyTitle: storyData['story_title'] ?? 'بدون عنوان',
      storyContent: parsedStoryContent,
      lessonWords: wordsData.map((e) => e['word'].toString()).toList(),
      comprehensionQuestions: compQuestions,
      vocabularyQuestions: vocabQuestions,
      comprehensionOpenEndedQuestions: openEndedQuestions,
      vocabularyFillInTheBlankQuestions: fillBlankQuestions,
    );
  }
}

// 2. Multiple Choice - Comprehension
class ComprehensionQuestion {
  final String question;
  final List<String> options;
  final String answer;
  ComprehensionQuestion(
      {required this.question, required this.options, required this.answer});
}

// 3. Multiple Choice - Vocabulary
class VocabularyQuestion {
  final String word;
  final String question;
  final List<String> options;
  final String answer;
  VocabularyQuestion(
      {required this.word,
      required this.question,
      required this.options,
      required this.answer});
}

// 4. Open Ended (Writing) - Comprehension
class OpenEndedQuestion {
  final String question;
  final String answerKey;
  OpenEndedQuestion({required this.question, required this.answerKey});
}

// 5. Fill in the Blank (Writing) - Vocabulary
class FillInTheBlankQuestion {
  final String wordAr;
  final String wordEn;
  FillInTheBlankQuestion({required this.wordAr, required this.wordEn});
}
