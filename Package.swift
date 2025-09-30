// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AWAirportsRepository",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AWAirportsRepository",
            targets: ["AWAirportsRepository"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        .target(
            name: "AWAirportsRepository",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift")
            ],
//            path: ".",
//            sources: [
//                "Models/Country.swift",
//                "Models/Region.swift",
//                "Models/Airport.swift",
//                "Models/AirportFrequency.swift",
//                "Models/Runway.swift",
//                "Models/Navaid.swift",
//                "Models/AirportComment.swift",
//                "AWAirportsRepository.swift"
//            ]
        ),
    ]
)
