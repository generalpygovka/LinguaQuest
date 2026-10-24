public struct Question {
    public let word: String
    public let options: [String]
    public let correctAnswerIndex: Int
    public let hint: String?

    public init(
        word: String,
        options: [String],
        correctAnswerIndex: Int,
        hint: String? = nil
    ) {
        self.word = word
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.hint = hint
    }
}
