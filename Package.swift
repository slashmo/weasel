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
		.target(name: "Weasel", dependencies: [
			.product(name: "Logging", package: "swift-log")
		]),
		.target(name: "Example", dependencies: [
			"Weasel",
			.product(name: "Logging", package: "swift-log")
		]),
		.testTarget(name: "WeaselTests", dependencies: ["Weasel"])
	]
)
