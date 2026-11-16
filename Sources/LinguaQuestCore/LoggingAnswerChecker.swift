public final class LoggingAnswerChecker: AnswerChecking {
    private let wrapped: any AnswerChecking
    private let log: (String) -> Void

    public init( wrapping wrapped: any AnswerChecking, log: @escaping (String) -> Void) 
    {
        self.wrapped = wrapped
        self.log = log
    }

    public func check( answerIndex: Int, question: Question) -> AnswerResult {
        let result = wrapped.check(
            answerIndex: answerIndex,
            question: question
        )

        log("\(question.word), індекс \(answerIndex): \(result)")

        return result
    }
}