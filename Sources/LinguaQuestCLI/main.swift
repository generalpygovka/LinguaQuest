print("LinguaQuest")
print("Добрий день! Тут ми будемо вивчати англійські слова.")

let question = Question(
    word: "apple",
    options: ["яблуко", "вікно", "книга"],
    correctAnswerIndex: 0
)

print()
print("Як перекладається слово «\(question.word)»?")

for index in question.options.indices {
    print("\(index + 1). \(question.options[index])")
}