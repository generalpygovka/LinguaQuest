import Foundation

public protocol LessonCatalogRepository {
    func loadLessons() throws -> [Lesson]

    func renameLesson(
        id: UUID,
        title: String
    ) throws -> Lesson
}

public enum LessonCatalogError: Error, Equatable {
    case lessonNotFound(id: UUID)
    case duplicateLessonID(id: UUID)
}

public final class InMemoryLessonCatalogRepository:
    LessonCatalogRepository
{
    private var lessons: [Lesson]

    public init(lessons: [Lesson]) throws {
        var identifiers = Set<UUID>()
        var validatedLessons: [Lesson] = []

        for lesson in lessons {
            guard identifiers.insert(lesson.id).inserted else {
                throw LessonCatalogError.duplicateLessonID(
                    id: lesson.id
                )
            }

            let validatedLesson =
                try Self.validatedLesson(lesson)

            validatedLessons.append(validatedLesson)
        }

        self.lessons = validatedLessons
    }

    public convenience init() throws {
        try self.init(
            lessons: [
                Lesson.beginner(),
                Lesson(
                    title: "Англійська в подорожі",
                    questions: [
                        Question(
                            word: "airport",
                            options: [
                                "аеропорт",
                                "готель",
                                "квиток"
                            ],
                            correctAnswerIndex: 0,
                            hint: "Звідси вилітають літаки."
                        ),
                        Question(
                            word: "ticket",
                            options: [
                                "валіза",
                                "квиток",
                                "потяг"
                            ],
                            correctAnswerIndex: 1,
                            hint: "Його купують для поїздки."
                        ),
                        Question(
                            word: "hotel",
                            options: [
                                "вокзал",
                                "парк",
                                "готель"
                            ],
                            correctAnswerIndex: 2
                        )
                    ]
                )
            ]
        )
    }

    public func loadLessons() throws -> [Lesson] {
        return lessons
    }

    public func renameLesson(
        id: UUID,
        title: String
    ) throws -> Lesson {
        guard let index = lessons.firstIndex(
            where: { $0.id == id }
        ) else {
            throw LessonCatalogError.lessonNotFound(id: id)
        }

        let originalLesson = lessons[index]

        let cleanedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let candidate = Lesson(
            id: originalLesson.id,
            title: cleanedTitle,
            questions: originalLesson.questions
        )

        let updatedLesson =
            try Self.validatedLesson(candidate)

        lessons[index] = updatedLesson

        return updatedLesson
    }

    private static func validatedLesson(
        _ lesson: Lesson
    ) throws -> Lesson {
        let builder = LessonBuilder(
            id: lesson.id,
            title: lesson.title
        )

        for question in lesson.questions {
            builder.addQuestion(question)
        }

        return try builder.build()
    }
}