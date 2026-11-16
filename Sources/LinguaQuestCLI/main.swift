import LinguaQuestCore

func showHint(for question: Question) {
    if let hint = question.hint {
        print("Підказка: \(hint)")
    } else {
        print("Для цього запитання підказки немає.")
    }
}

func runLesson(_ session: LessonSession) {
    print("LinguaQuest — \(session.lesson.title)")
    print("Введіть номер відповіді й натисніть Enter.")
    print("Щоб отримати підказку, введіть ?")
    print("Правильна відповідь: +1 бал.")
    print("Невиконане запитання: 0 балів.")

    while !session.isCompleted {
        guard let question = session.currentQuestion else {
            print("Не вдалося отримати поточне запитання.")
            return
        }

        print()
        print(
            "Питання \(session.questionIndex + 1): " +
            "як перекладається «\(question.word)»?"
        )

        for optionIndex in question.options.indices {
            print(
                "\(optionIndex + 1). " +
                "\(question.options[optionIndex])"
            )
        }

        while !session.questionFinished {
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
                print(
                    "Введіть число від 1 " +
                    "до \(question.options.count) " +
                    "або ? для підказки."
                )
                continue
            }

            let answerIndex = answerNumber - 1

            guard let result = session.submitAnswer(answerIndex) else {
                print("Не вдалося прийняти відповідь.")
                return
            }

            switch result {
            case .correct:
                print("Правильно! +1 бал.")

            case .incorrect:
                if session.questionFinished {
                    let correctAnswer =
                        question.options[question.correctAnswerIndex]

                    print("Цього разу неправильно.")
                    print(
                        "Правильна відповідь: \(correctAnswer)."
                    )
                } else {
                    print(
                        "Неправильно. Спробуй ще раз " +
                        "або введи ? для підказки."
                    )
                }

            case .invalid:
                print("Помилка: не вдалося перевірити відповідь.")
                return
            }
        }

        print("Поточні бали: \(session.score).")

        guard session.nextQuestion() else {
            print("Не вдалося перейти до наступного запитання.")
            return
        }
    }

    print()
    print("Урок завершено!")
    print(
        "Правильно виконано запитань: " +
        "\(session.correctAnswers) із " +
        "\(session.lesson.questionCount)."
    )
    print(
        "Бали: \(session.score). " +
        "Максимум: \(session.lesson.questionCount)."
    )
}

let repository: any LessonRepository = InMemoryLessonRepository()

do {
    let lesson = try repository.loadLesson()

    let checker: any AnswerChecking = LoggingAnswerChecker(
        wrapping: AnswerChecker(),
        log: { message in
            print("[Перевірка] \(message)")
        }
    )

    let session = try LessonSession(
        lesson: lesson,
        checker: checker,
        points: { isCorrect in
            return isCorrect ? 1 : 0
        }
    )

    runLesson(session)
} catch {
    print("Не вдалося підготувати урок: \(error)")
}
