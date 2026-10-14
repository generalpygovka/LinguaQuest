struct Lesson {
    let title: String
    let questions: [Question]

    init(title: String, questions: [Question]) {
        self.title = title
        self.questions = questions
    }

    var questionCount: Int {
        return questions.count
    }

    static func beginner() -> Lesson {
        return Lesson(
            title: "Перші кроки англійською",
            questions: [
                Question(
                    word: "apple",
                    options: ["яблуко", "вікно", "книга"],
                    correctAnswerIndex: 0,
                    hint: "Це фрукт."
                ),
                Question(
                    word: "book",
                    options: ["стіл", "книга", "вода"],
                    correctAnswerIndex: 1,
                    hint: "Її читають."
                ),
                Question(
                    word: "sun",
                    options: ["місяць", "дощ", "сонце"],
                    correctAnswerIndex: 2
                )
            ]
        )
    }
}