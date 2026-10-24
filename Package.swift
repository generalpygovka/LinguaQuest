// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "LinguaQuest",
    products: [
        .library(
            name: "LinguaQuestCore",
            targets: ["LinguaQuestCore"]
        ),
        .executable(
            name: "LinguaQuestCLI",
            targets: ["LinguaQuestCLI"]
        )
    ],
    targets: [
        .target(
            name: "LinguaQuestCore"
        ),
        .executableTarget(
            name: "LinguaQuestCLI",
            dependencies: ["LinguaQuestCore"]
        )
    ]
)
