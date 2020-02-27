// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "weasel",
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.2.0"))
	],
	targets: [
		.target(name: "App", dependencies: ["Logging"]),
		.target(name: "Run", dependencies: ["App", "Logging"]),
		.testTarget(name: "AppTests", dependencies: ["App"])
	]
)
