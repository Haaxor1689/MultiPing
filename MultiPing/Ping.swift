//
//  Ping.swift
//  globalvpn
//
//  Created by Maros Betko on 26/07/2017.
//  Copyright © 2017 master app solutions. All rights reserved.
//

import Foundation

public typealias PingCompletionBlock = (SimplePingResponse)->()

public enum SimplePingResponse {
	case notStarted(withError: Error)
	case notSent(withError: Error)
	case timedOut
	case succeeded(withLatency: TimeInterval)
}

fileprivate class PingConfig {
	let pinger: SimplePing
	
	let completion: PingCompletionBlock?
	
	var timer: Timer!
	let timeout: TimeInterval
	var pingStart: TimeInterval!
	
	var retries: Int
	
	init(_ delegate: Ping, _ address: String, _ timeout: TimeInterval, _ retries: Int, _ completion: PingCompletionBlock?) {
		pinger = SimplePing(hostName: address)
		pinger.delegate = delegate
		pinger.start()
		
		self.completion = completion
		self.timeout = timeout
		self.retries = retries
	}
}

public class Ping: NSObject, SimplePingDelegate {
	public static let shared = Ping()
	private var tasks = [String : PingConfig]()
	
	public func start(_ address: String, timeout: TimeInterval = 3, retries: Int = 5, completion: PingCompletionBlock? = nil) {
		guard tasks[address] == nil else {
			print("Alredy pinging " + address)
			return
		}
		
		tasks[address] = PingConfig(self, address, timeout, retries, completion)
	}
	
	public func stop(_ address: String) {
		removeTask(for: address)
	}
	
	public func stopAll() {
		for (address, config) in tasks {
			config.timer?.invalidate()
			config.pinger.stop()
			
			tasks.removeValue(forKey: address)
			print("Ping " + address + ": removed")
		}
	}
	
	private func getConfig(for pinger: SimplePing) -> (String, PingConfig)? {
		for (name, config) in tasks {
			if config.pinger == pinger {
				return (name, config)
			}
		}
		return nil
	}
	
	private func removeTask(for address: String) {
		guard let config = tasks[address] else {
			print("Tried to remove non-existent task with address " + address)
			return
		}
		
		config.timer?.invalidate()
		config.pinger.stop()
		tasks.removeValue(forKey: address)
		print("Ping " + address + ": removed")
	}
	
	// MARK: - SimplePingDelegate methods
	public func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
		guard let (address, config) = getConfig(for: pinger) else {
			print("Error: callback from unregistered pinger.")
			return
		}
		
		print("Ping " + address + ": didStartWithAddress")
		
		config.timer = Timer.scheduledTimer(timeInterval: config.timeout, target: self, selector: #selector(timedOut), userInfo: (address, config), repeats: false)
		config.pingStart = Date.timeIntervalSinceReferenceDate
		config.pinger.send(with: nil)
	}
	
	public func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
		guard let (address, _) = getConfig(for: pinger) else {
			print("Error: callback from unregistered pinger.")
			return
		}
		
		print("Ping " + address + ": didSendPacket")
	}
	
	public func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
		guard let (address, config) = getConfig(for: pinger) else {
			print("Error: callback from unregistered pinger.")
			return
		}
		
		print("Ping " + address + ": didReceivePingResponsePacket")
		config.completion?(.succeeded(withLatency: Date.timeIntervalSinceReferenceDate - config.pingStart))
		removeTask(for: address)
	}
	
	public func simplePing(_ pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) {
		//print("didReceiveUnexpectedPacket")
	}
	
	public func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
		guard let (address, config) = getConfig(for: pinger) else {
			print("Error: callback from unregistered pinger.")
			return
		}
		
		print("Ping " + address + ": didFailToSendPacket")
		retryPing(for: address, withConfig: config, else: {
			config.completion?(.notSent(withError: error))
			self.removeTask(for: address)
		})
	}
	
	public func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
		guard let (address, config) = getConfig(for: pinger) else {
			print("Error: callback from unregistered pinger.")
			return
		}
		
		print("Ping " + address + ": didFailWithError")
		retryPing(for: address, withConfig: config, else: {
			config.completion?(.notStarted(withError: error))
			self.removeTask(for: address)
		})
	}
	
	@objc private func timedOut(_ timer: Timer) {
		guard let (address, config) = timer.userInfo as? (String, PingConfig) else {
			print("Error: callback from unregistered pinger.")
			return
		}
		
		print("Ping " + address + ": didTimedOut")
		retryPing(for: address, withConfig: config, else: {
			config.completion?(.timedOut)
			self.removeTask(for: address)
		})
	}
	
	private func retryPing(for address: String, withConfig config: PingConfig, else continueBlock: (()->())? = nil) {
		if config.retries > 0 {
			print("Ping " + address + ": retrying")
			config.retries -= 1
			
			config.timer?.invalidate()
			config.timer = Timer.scheduledTimer(timeInterval: config.timeout, target: self, selector: #selector(timedOut), userInfo: (address, config), repeats: false)
			config.pingStart = Date.timeIntervalSinceReferenceDate
			config.pinger.send(with: nil)
		} else {
			continueBlock?()
		}
	}
}
