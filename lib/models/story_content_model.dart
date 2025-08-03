import 'package:flutter/foundation.dart';

// 1. The main container for all content
class StoryContent {
final String storyTitle;
final String storyEn;
final String storyAr;
final List<String> lessonWords;
final List<ComprehensionQuestion> comprehensionQuestions;
final List<VocabularyQuestion> vocabularyQuestions;
final List<OpenEndedQuestion> comprehensionOpenEndedQuestions;
final List<FillInTheBlankQuestion> vocabularyFillInTheBlankQuestions;

StoryContent({
required this.storyTitle,
required this.storyEn,
required this.storyAr,
required this.lessonWords,
required this.comprehensionQuestions,
required this.vocabularyQuestions,
required this.comprehensionOpenEndedQuestions,
required this.vocabularyFillInTheBlankQuestions,
});

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

for (var q in questionsData) {
final questionText = q['qestion'] as String;

if (questionText.startsWith('open_ended:')) {
openEndedQuestions.add(OpenEndedQuestion(
question: questionText.replaceFirst('open_ended:', '').trim(),
answerKey: q['choice_correct'] ?? '',
));
} else if (questionText.startsWith('fill_in_the_blank:')) {
fillBlankQuestions.add(FillInTheBlankQuestion(
wordAr: questionText.replaceFirst('fill_in_the_blank:', '').trim(),
wordEn: q['choice_correct'] ?? '',
));
} else {
final options = [
q['choice1'], q['choice2'], q['choice3'], q['choice4']
].where((c) => c != null).toList().cast<String>();

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

return StoryContent(
storyTitle: storyData['story_title'] ?? 'بدون عنوان',
storyEn: storyData['story_en'] ?? '',
storyAr: storyData['story_ar'] ?? '',
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
ComprehensionQuestion({required this.question, required this.options, required this.answer});
}

// 3. Multiple Choice - Vocabulary
class VocabularyQuestion {
final String word;
final String question;
final List<String> options;
final String answer;
VocabularyQuestion({required this.word, required this.question, required this.options, required this.answer});
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


