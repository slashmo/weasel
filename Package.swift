// swift-tools-version:5.2
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
		.target(name: "Async", dependencies: []),
		.testTarget(name: "AsyncTests", dependencies: ["Async"]),

		.target(name: "Weasel", dependencies: [
			"Async",
			.product(name: "Logging", package: "swift-log")
		]),
		.testTarget(name: "WeaselTests", dependencies: ["Weasel"]),

		.target(name: "Example", dependencies: [
			"Weasel",
			.product(name: "Logging", package: "swift-log")
		])
	]
)
