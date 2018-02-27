# MultiPing

## Description

Swift library for sending multiple asynchronous ping request to multiple servers. Available on cocoapods.

## Usage

To start pinging call `Ping.start(address:timeout:retries:completion)` on a `Ping.shared` instance, or create your own instance of Ping class. All arguments except address are optional and can be left out.

```swift
Ping.shared.start("[address]", timeout: 5, retires: 3) { response in
	switch response {
	case .notSent(let error):
		/* ... */
	case .timedOut:
		/* ... */
	case .succeeded(let latency);
		/* ... */
	}
}
```

To stop ping request in progress call `Ping.stop(address)` on instance you started the ping on. This will stop any possible retries and safely discard all responses from given address.

```swift
Ping.shared.stop("[address]")
```

To stop all ping requests at once use `Ping.stopAll()`. This will stop all pings that are handled by the instance of Ping class you call it on.

```swift
Ping.shared.stopAll()
```

## Installation

Into your Podfile add:

```
pod 'MultiPing'
```

## Chagelog

* 0.1.1:
	* Changed to singleton pattern
	* You can start ping on a static `shared` instance or create a new instance of Ping class with it's default constructor
	* Added `Ping.removeAll()` that removes all pings in progress from given instance of Ping class
* 0.1.0:
	* Initial version	
