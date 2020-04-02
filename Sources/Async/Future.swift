import Dispatch

/// An abstract generic class used to handle asynchronous tasks.
/// Its `Result` can be observed by calling the `observe` method.
/// - Note: Although you may observe its result multiple times, a `Future` only produces one value.
/// If observed after a `Result` has been produced the given result is reported immediately.
public class Future<Success, Failure: Error> {
	/// A closure representing the observation of a future `Result`.
	public typealias Observer = (Result<Success, Failure>) -> Void

	private var observers = [Observer]()
	private let observersSyncQueue = DispatchQueue(label: "codes.slashmo.weasel.Future", attributes: .concurrent)

	fileprivate var result: Result<Success, Failure>? {
		didSet {
			result.map(report)
		}
	}

	/// Register the given `Observer` to be called once a `Result` was produced.
	/// - Parameter observer: The `Observer` to be called.
	/// - Note: If a `Result` has already been produced, the `Observer` is called immediately.
	public func observe(with observer: @escaping Observer) {
		if let previousResult = result {
			report(previousResult, to: observer)
			return
		}

		observersSyncQueue.sync(flags: .barrier) {
			observers.append(observer)
		}
	}

	private func report(_ result: Result<Success, Failure>) {
		observersSyncQueue.sync(flags: .barrier) {
			observers.forEach { report(result, to: $0) }
			observers = []
		}
	}

	private func report(_ result: Result<Success, Failure>, to observer: Observer) {
		observer(result)
	}
}

/// A concrete subclass of `Future` adding the functionality to report a `Result`.
///
/// Typically, you'll use a `Promise` as a means of returning a `Future` inside of a function:
///
///     func foo() -> Future<String, FooError> {
///         let promise = Promise<String, FooError>()
///         performAsyncTask {
///             promise.report(.success("bar"))
///         }
///         return promise
///     }
public final class Promise<Success, Failure: Error>: Future<Success, Failure> {
	/// Initialize a `Promise`.
	public override init() {
		super.init()
	}

	/// Report the given `Result` to all `Observer`s. Future `Observer`s will also be able to read this `Result`.
	/// - Parameter result: The `Result` to be reported to all current and future `Observer`s.
	public func report(_ result: Result<Success, Failure>) {
		self.result = result
	}
}
