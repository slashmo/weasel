// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "weasel",
	targets: [
		.target(name: "App", dependencies: []),
		.target(name: "Run", dependencies: ["App"]),
		.testTarget(name: "AppTests", dependencies: ["App"])
	]
)
