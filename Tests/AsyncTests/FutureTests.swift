import Async
import XCTest

final class FutureTests: XCTestCase {
    func testObserversAreCalled() {
        var result1: Result<String, Error>?
        var result2: Result<String, Error>?
        var result3: Result<String, Error>?

        let promise = Promise<String, Error>()
        let future = promise as Future

        future.observe { observedResult in
            result1 = observedResult
        }
        future.observe { observedResult in
            result2 = observedResult
        }

        promise.report(.success("test"))

        future.observe { observedResult in
            result3 = observedResult
        }

        XCTAssertEqual(result1, .success("test"))
        XCTAssertEqual(result2, .success("test"))
        XCTAssertEqual(result3, .success("test"))
    }

    func testThreadSafety() {
        let promise = Promise<Int, Error>()
        let future = promise as Future

        for _ in 0 ..< 100 {
            let reportExpectation = expectation(description: "future result reported")
            DispatchQueue.global().async {
                future.observe { result in
                    XCTAssertEqual(result, .failure(.test))
                    reportExpectation.fulfill()
                }
            }
        }

        DispatchQueue.global().async {
            promise.report(.failure(.test))
        }

        waitForExpectations(timeout: 0.2)
    }
}

private enum Error: Swift.Error {
    case test
}
