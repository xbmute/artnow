import PackageDescription

let package = Package(
    name: "artnow",
    dependencies: [
        .Package(
        url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git",
        majorVersion: 2
        ),
        .Package(
        url: "https://github.com/JohnSundell/Files.git",
        majorVersion: 1
        )
    ]
)
