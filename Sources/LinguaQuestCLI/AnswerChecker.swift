enum AnswerResult {
    case correct
    case incorrect
    case invalid
}

protocol AnswerChecking {
    func check(
        answerIndex: Int,
        question: Question
    ) -> AnswerResult
}

class AnswerChecker: AnswerChecking {
    func check(
        answerIndex: Int,
        question: Question
    ) -> AnswerResult {
        guard question.options.indices.contains(answerIndex),
              question.options.indices.contains(question.correctAnswerIndex)
        else {
            return .invalid
        }

        if answerIndex == question.correctAnswerIndex {
            return .correct
        } else {
            return .incorrect
        }
    }
}