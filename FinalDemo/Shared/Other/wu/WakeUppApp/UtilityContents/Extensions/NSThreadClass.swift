//
//  NSThreadClass.swift
//  SwiftDemo
//


import Foundation

/**
Runs a block in the main thread
**/
private func runOnMainThread(block: @escaping () -> ()) {
    DispatchQueue.main.async {
        block()
    }
}

/**
 Runs a block in background
 */
public func runInBackground(block: @escaping () -> ()) {
    
    DispatchQueue.global(qos: .userInitiated).async {
        block()
    }
}

public func runOnMainThreadWithoutDeadlock(block: @escaping () -> ()) {
    
    if(Thread.isMainThread)
    {
        block()
    }
    else
    {
        runOnMainThread {
            block()
        }
    }
}

/**
 Runs a block after given time
 */
public func runAfterTime(time: Double, block: @escaping () -> ()) {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
        block()
    })
}


