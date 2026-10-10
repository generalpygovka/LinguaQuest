struct Question {
    let word: String
    let options: [String]
    let correctAnswerIndex: Int

    init(word: String, options: [String], correctAnswerIndex: Int) {
        self.word = word
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
    }
}