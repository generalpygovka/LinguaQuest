struct Question {
    let word: String
    let options: [String]
    let correctAnswerIndex: Int
    let hint: String?

    init(word: String, options: [String], correctAnswerIndex: Int, hint: String? = nil)
    {
        self.word = word
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.hint = hint
    }
}