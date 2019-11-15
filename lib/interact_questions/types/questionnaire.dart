class Questionnaire {
    String id;
    String courseId;
    String name;
    int questionsLength;
    List<QuestionnaireQuestion> questions;

    Questionnaire(
      this.id,
      this.courseId,
      this.name,
      this.questionsLength,
      this.questions,
    );
}  

class QuestionnaireQuestion {
  String id;
  String question;
  int time;
  List<QuestionnaireQuestionAnswer> answers;
  
  QuestionnaireQuestion(
    this.id,
    this.question,
    this.time,
    this.answers,
  );
}

class QuestionnaireQuestionAnswer {
  String id;
  String answer;
  bool correct;
  QuestionnaireQuestionAnswer(
    this.id,
    this.answer,
    this.correct,
  );
}
