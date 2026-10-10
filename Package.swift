// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "LinguaQuest",
    products: [
        .executable(
            name: "LinguaQuestCLI",
            targets: ["LinguaQuestCLI"]
        )
    ],
    targets: [
        .executableTarget(
            name: "LinguaQuestCLI"
        )
    ]
)