import SwiftUI

@MainActor
struct LessonResultView: View {
    let lessonTitle: String
    let correctAnswers: Int
    let questionCount: Int
    let score: Int

    let onRestart: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Урок завершено!")
                    .font(.largeTitle)
                    .bold()

                Text(lessonTitle)
                    .font(.title2)

                Text(
                    "Правильно виконано запитань: " +
                    "\(correctAnswers) із \(questionCount)."
                )
                .font(.headline)

                Text(
                    "Бали: \(score). " +
                    "Максимум: \(questionCount)."
                )

                Button("Пройти ще раз") {
                    onRestart()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}
