func showHint(for question: Question) {
    if let hint = question.hint {
        print("Підказка: \(hint)")
    } else {
        print("Для цього запитання підказки немає.")
    }
}

func runLesson(
    _ lesson: Lesson,
    checker: any AnswerChecking
) {
    var correctAnswers = 0
    var score = 0

    print("LinguaQuest — \(lesson.title)")
    print("Введіть номер відповіді й натисніть Enter.")
    print("Щоб отримати підказку, введіть ?")
    print("Правильна відповідь: +1 бал.")
    print("Неправильна відповідь: -1 бал.")

    guard !lesson.questions.isEmpty else {
        print("У цьому уроці поки немає запитань.")
        return
    }

    for (questionIndex, question) in lesson.questions.enumerated() {
        guard !question.options.isEmpty else {
            print("Помилка: у запитанні немає варіантів відповіді.")
            return
        }

        print()
        print(
            "Питання \(questionIndex + 1): " +
            "як перекладається «\(question.word)»?"
        )

        for optionIndex in question.options.indices {
            print(
                "\(optionIndex + 1). " +
                "\(question.options[optionIndex])"
            )
        }

        var wrongAttempts = 0
        var questionFinished = false

        while !questionFinished {
            print("Ваша відповідь: ", terminator: "")

            guard let input = readLine() else {
                print()
                print("Введення завершено. Урок перервано.")
                return
            }

            if input == "?" {
                showHint(for: question)
                continue
            }

            guard let answerNumber = Int(input),
                  answerNumber >= 1,
                  answerNumber <= question.options.count
            else {
                print("Введіть число від 1 " + "до \(question.options.count) " + "або ? для підказки.")
                continue
            }

            let answerIndex = answerNumber - 1

            let result = checker.check(
                answerIndex: answerIndex,
                question: question
            )

            switch result {
            case .correct:
                correctAnswers += 1
                score += 1
                questionFinished = true

                print("Правильно! +1 бал.")

            case .incorrect:
                wrongAttempts += 1

                if wrongAttempts == 1 {
                    print("Неправильно. Маєш ще одну спробу (напиши ? для підказки).")
                } else {
                    score -= 1
                    questionFinished = true

                    let correctAnswer =
                        question.options[question.correctAnswerIndex]

                    print("Неправильно вдруге. -1 бал.")
                    print(
                        "Правильна відповідь: \(correctAnswer)."
                    )
                }

            case .invalid:
                print("Помилка: некоректні дані запитання.")
                return
            }
        }

        print("Поточні бали: \(score).")
    }

    print()
    print("Урок завершено!")
    print(
        "Правильно виконано запитань: " +
        "\(correctAnswers) із \(lesson.questionCount)."
    )
    print(
        "Бали: \(score). Максимум: \(lesson.questionCount)."
    )
}

let lesson = Lesson.beginner()
let checker: any AnswerChecking = AnswerChecker()

runLesson(lesson, checker: checker)