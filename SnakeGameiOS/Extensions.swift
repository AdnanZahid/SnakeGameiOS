//
//  Extensions.swift
//  SnakeGameiOS
//
//  Created by AdnanZahid on 1/29/18.
//  Copyright © 2018 AdnanZahid. All rights reserved.
//

import UIKit

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ** : PowerPrecedence
func ** (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension Bool: IntValue {
    func intValue() -> Int {
        if self {
            return 1
        }
        return 0
    }
}

protocol IntValue {
    func intValue() -> Int
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

private let _wordSize = __WORDSIZE

public extension UInt32 {
    public static func random(lower: UInt32 = min, upper: UInt32 = max) -> UInt32 {
        return arc4random_uniform(upper - lower) + lower
    }
}

public extension Int32 {
    public static func random(lower: Int32 = min, upper: Int32 = max) -> Int32 {
        let r = arc4random_uniform(UInt32(Int64(upper) - Int64(lower)))
        return Int32(Int64(r) + Int64(lower))
    }
}

public extension UInt64 {
    public static func random(lower: UInt64 = min, upper: UInt64 = max) -> UInt64 {
        return UInt64(arc4random_uniform(UInt32(upper - lower))) + lower
    }
}

public extension Int64 {
    public static func random(lower: Int64 = min, upper: Int64 = max) -> Int64 {
        let r = arc4random_uniform(UInt32(Int64(Int64(upper) - Int64(lower))))
        return Int64(Int64(r) + Int64(lower))
    }
}

public extension UInt {
    public static func random(lower: UInt = min, upper: UInt = max) -> UInt {
        switch (_wordSize) {
        case 32: return UInt(UInt32.random(lower: UInt32(lower), upper: UInt32(upper)))
        case 64: return UInt(UInt64.random(lower: UInt64(lower), upper: UInt64(upper)))
        default: return lower
        }
    }
}

public extension Int {
    public static func random(lower: Int = min, upper: Int = max) -> Int {
        switch (_wordSize) {
        case 32: return Int(Int32.random(lower: Int32(lower), upper: Int32(upper)))
        case 64: return Int(Int64.random(lower: Int64(lower), upper: Int64(upper)))
        default: return Int(Int32.random(lower: Int32(lower), upper: Int32(upper)))
        }
    }
}
