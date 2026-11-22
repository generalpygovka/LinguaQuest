# LinguaQuest

## Предметна область

Навчальний застосунок для коротких уроків англійської мови.

## Користувач

Людина, яка починає вивчати англійську та тренує переклад слів.

## Основний сценарій

Користувач обирає урок у каталозі, відповідає на запитання
та переглядає результат. Назву уроку можна змінити
в модальному редакторі.

Правильна відповідь дає 1 бал. Перша помилка дозволяє повторну
спробу, друга завершує запитання з 0 балів і показує переклад.
Підказка не витрачає спробу.

Повернення до каталогу зберігає незавершене проходження.
Повторне проходження скидає результат. Назви та прогрес
зберігаються в пам’яті протягом роботи застосунку.

## Основні сутності

| Сутність | Дані                                                        |
|----------|-------------------------------------------------------------|
| Question | Слово, варіанти, правильний індекс, необов’язкова підказка     |
| Lesson   | UUID, назва та масив запитань                                |

## Архітектура

iOS використовує MVVM та окремий AppRouter для навігації.
Спільна бібліотека LinguaQuestCore містить моделі,
репозиторії та правила проходження LessonSession.
Її використовують iOS і консольна версія.

Реалізовані патерни: Builder, Decorator та Observer.

- [Архітектура, SOLID і залежності](docs/architecture.md).
- [Карта навігації, сценарій і скриншоти](docs/navigation.md).
- [Каталог, перейменування та перевірка даних](docs/lab3-data.md).

## Конструкції Swift

| Конструкція             | Приклад                                      |
|-------------------------|----------------------------------------------|
| struct                  | Question, Lesson                             |
| class                   | AnswerChecker, LessonSession                 |
| protocol                | AnswerChecking, LessonCatalogRepository      |
| enum                    | AnswerResult, AppRoute                       |
| let і var               | Незмінні моделі та змінний стан сесії         |
| Властивості та init     | Question, Lesson, LessonSession               |
| Обчислювані властивості | Lesson.questionCount, currentQuestion        |
| Методи                  | Lesson.beginner(), submitAnswer(...)         |
| Колекції                | Question.options, Lesson.questions           |
| Optional                | Question.hint, currentQuestion               |
| Безпечне розгортання    | if let, guard let                            |
| Умови та цикли          | if, guard, switch, for, while                 |
| Обробка помилок         | throws, throw, do/catch                       |

Спільні компоненти: Sources/LinguaQuestCore.
Консольний сценарій: Sources/LinguaQuestCLI/main.swift.
Інтерфейс і ViewModel: iOS/LinguaQuest/LinguaQuest.

## Підготовка та запуск

Xcode: 16.2. Мінімальна версія iOS: 18.2.

1. Клонувати весь репозиторій у папку LinguaQuest.
2. Відкрити iOS/LinguaQuest/LinguaQuest.xcodeproj.
3. За потреби встановити компонент iOS Simulator.
4. Вибрати схему LinguaQuest, симулятор iPhone та натиснути Run.

Спільний пакет підключено локально. Зовнішніх залежностей немає.

Консоль із кореня репозиторію:

    swift run LinguaQuestCLI

У налаштованому Windows-середовищі:

    swift run --build-system native LinguaQuestCLI

## Перевірки

| Набір                   | Кількість | Запуск                 |
|-------------------------|-----------|------------------------|
| Тести спільного пакета  | 13        | swift test             |
| iOS-тести               | 20        | Схема LinguaQuest, ⌘U  |

На Windows: swift test --build-system native.

Інтерфейс перевірено на iPhone SE (3rd generation)
та iPhone 16 Pro з iOS 18.3.
Сценарій перевірки та зображення наведені в docs/navigation.md.

## Внесок учасників

- generalpygovka: Question, консольний сценарій, LessonSession,
  LessonViewModel, екрани, Router, прогрес, анімація,
  тести проходження та інтеграція.
- dii02-svg: Lesson, перевіряльник, спільний пакет,
  репозиторії, Builder, Decorator, каталог,
  LessonCatalogViewModel і тести компонентів та каталогу.
