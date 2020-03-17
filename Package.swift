// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "weasel",
	products: [
		.library(name: "Weasel", targets: ["Weasel"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.2.0"))
	],
	targets: [
		.target(name: "Weasel", dependencies: ["Logging"]),
		.target(name: "Example", dependencies: ["Weasel", "Logging"]),
		.testTarget(name: "WeaselTests", dependencies: ["Weasel"])
	]
)
