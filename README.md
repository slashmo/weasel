# Weasel HTTP Server

[![Swift 5.2](https://img.shields.io/badge/swift-5.2-ED523F.svg?style=flat)](https://swift.org/download/)
[![Continuous Integration](https://github.com/slashmo/weasel/workflows/Continuous%20Integration/badge.svg)](https://github.com/slashmo/weasel/actions?query=workflow%3A%22Continuous+Integration%22)

## Do not use in production

🏗👨‍🎓 Weasel is an HTTP Server implementation written in [Swift](https://github.com/apple/swift). It's sole purpose is for me to learn about HTTP and lower-level code.

## Demo

[`Weasel`](https://github.com/slashmo/weasel/tree/master/Sources/Weasel) itself is a Swift library package that you, in theory, could **but definetely shouldn't** use in your own backend applications. Included in this repository is also an executable [`Example`](https://github.com/slashmo/weasel/tree/master/Sources/Example) which spins up an HTTP Server using the `Weasel` library.

```sh
swift package resolve
swift run
```

### Projects inspiring this implementation

- [Swift NIO](https://github.com/apple/swift-nio)
- [Vapor](https://github.com/vapor/vapor)
