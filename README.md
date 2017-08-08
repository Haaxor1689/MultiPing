# MultiPing
## Description
Simple pod, that allows you to ping multiple addresses at the same time.
## Usage
To start pinging call `Ping.start(address:timeout:retries:completion)`. All arguments except address are optional and can be left out.

```swift
Ping.start("[address]", timeout: 5, retires: 3) { response in
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

To stop ping request in progress call `Ping.stop(address)`. This will stop any possible retries and safely discard all responses from given address.

```swift
Ping.stop("[address]")
```

## Installation
Into your Podfile add:

```
pod 'MultiPing'
```
