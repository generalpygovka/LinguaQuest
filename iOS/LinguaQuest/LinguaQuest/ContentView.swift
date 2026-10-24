import SwiftUI
import LinguaQuestCore

struct ContentView: View {
    private let lesson = Lesson.beginner()
    private let checker: any AnswerChecking = AnswerChecker()

    @State private var questionIndex = 0
    @State private var correctAnswers = 0
    @State private var score = 0
    @State private var wrongAttempts = 0
    @State private var questionFinished = false
    @State private var hintVisible = false
    @State private var message = ""

    private var currentQuestion: Question? {
        guard lesson.questions.indices.contains(questionIndex) else {
            return nil
        }

        return lesson.questions[questionIndex]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("LinguaQuest")
                    .font(.largeTitle)
                    .bold()

                Text(lesson.title)
                    .font(.title2)

                Text("Бали: \(score)")
                    .font(.headline)

                if lesson.questions.isEmpty {
                    Text("У цьому уроці поки немає запитань.")
                } else if let question = currentQuestion {
                    questionView(for: question)
                } else {
                    resultsView
                }
            }
            .padding()
        }
    }

    private func questionView(for question: Question) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(
                "Запитання \(questionIndex + 1) " +
                "із \(lesson.questionCount)"
            )
            .foregroundStyle(.secondary)

            Text("Як перекладається слово?")
                .font(.headline)

            Text(question.word)
                .font(.largeTitle)
                .bold()

            ForEach(question.options.indices, id: \.self) { index in
                Button {
                    checkAnswer(index, for: question)
                } label: {
                    Text(question.options[index])
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .disabled(questionFinished)
            }

            Button("Підказка") {
                hintVisible = true
            }
            .buttonStyle(.bordered)
            .disabled(questionFinished)

            if hintVisible {
                if let hint = question.hint {
                    Text("Підказка: \(hint)")
                } else {
                    Text("Для цього запитання підказки немає.")
                }
            }

            if !message.isEmpty {
                Text(message)
                    .font(.headline)
            }

            if questionFinished {
                Button(
                    questionIndex + 1 == lesson.questionCount
                    ? "Завершити урок"
                    : "Наступне запитання"
                ) {
                    questionIndex += 1
                    resetQuestion()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var resultsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Урок завершено!")
                .font(.title)
                .bold()

            Text(
                "Правильно виконано запитань: " +
                "\(correctAnswers) із \(lesson.questionCount)."
            )

            Text(
                "Бали: \(score). " +
                "Максимум: \(lesson.questionCount)."
            )

            Button("Пройти ще раз") {
                questionIndex = 0
                correctAnswers = 0
                score = 0
                resetQuestion()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func checkAnswer(
        _ answerIndex: Int,
        for question: Question
    ) {
        guard !questionFinished else {
            return
        }

        let result = checker.check(
            answerIndex: answerIndex,
            question: question
        )

        switch result {
        case .correct:
            correctAnswers += 1
            score += 1
            questionFinished = true

            message = "Правильно! +1 бал."

        case .incorrect:
            wrongAttempts += 1

            if wrongAttempts == 1 {
                message =
                    "Неправильно. Спробуй ще раз " +
                    "або скористайся підказкою."
            } else {
                score -= 1
                questionFinished = true

                let correctAnswer =
                    question.options[question.correctAnswerIndex]

                message =
                    "Неправильно. −1 бал.\n" +
                    "Правильна відповідь: \(correctAnswer)."
            }

        case .invalid:
            message = "Помилка: некоректні дані запитання."
        }
    }

    private func resetQuestion() {
        wrongAttempts = 0
        questionFinished = false
        hintVisible = false
        message = ""
    }
}
