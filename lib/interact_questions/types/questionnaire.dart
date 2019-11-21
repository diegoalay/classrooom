class Questionnaire {
    String id;
    String courseId;
    String name;
    int questionsLength;
    int questionIndex;
    List<QuestionnaireQuestion> questions;

    Questionnaire(
      this.id,
      this.courseId,
      this.name,
      this.questionsLength,
      this.questionIndex,
      this.questions,
    );
}  

class QuestionnaireQuestion {
  String id;
  String question;
  int time;
  int questionIndex;
  int correctAnswer;
  List<QuestionnaireQuestionAnswer> answers;
  
  QuestionnaireQuestion(
    this.id,
    this.question,
    this.time,
    this.questionIndex,
    this.correctAnswer,
    this.answers,
  );
}

class QuestionnaireQuestionAnswer {
  String id;
  String answer;
  QuestionnaireQuestionAnswer(
    this.id,
    this.answer,
  );
}
