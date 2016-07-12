//
//  Lazy.swift
//  Lazy
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Nikolai Vazquez
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

/// A lazy enclosure around a value.
public struct Lazy<Value>: CustomStringConvertible, CustomDebugStringConvertible {

    private var _ref: _LazyRef<Value>

    /// The value for `self`.
    public var value: Value {
        get {
            if let value = _ref.value {
                return value
            } else {
                let value = _ref.closure()
                _ref.value = value
                return value
            }
        }
        set {
            if !isUniquelyReferencedNonObjC(&_ref) {
                _ref = _LazyRef(value: newValue, closure: { newValue })
            } else {
                _ref.value = newValue
            }
        }
    }

    /// `true` if `value` is initialized.
    public var isInitialized: Bool {
        return _ref.value != nil
    }

    /// A textual representation of this instance.
    public var description: String {
        return "Lazy(\(_ref.value.map(String.init(_:)) ?? "Uninitialized"))"
    }

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return "Lazy(\(_ref.value.map(String.init(reflecting:)) ?? "Uninitialized"))"
    }

    #if swift(>=3)

    /// Create a lazy value.
    public init(_ value: @autoclosure(escaping) () -> Value) {
        _ref = _LazyRef(value)
    }

    #else

    /// Create a lazy value.
    public init(@autoclosure(escaping) _ value: () -> Value) {
        _ref = _LazyRef(value)
    }

    #endif
    
}

/// Implementation detail for `Lazy<Value>`.
private final class _LazyRef<Value> {

    var value: Value?

    var closure: () -> Value

    #if swift(>=3)

    init(_ value: @autoclosure(escaping) () -> Value) {
        closure = value
    }

    #else

    init(@autoclosure(escaping) _ value: () -> Value) {
        closure = value
    }

    #endif

    init(value: Value?, closure: () -> Value) {
        self.value = value
        self.closure = closure
    }

}

#if swift(>=3)

/// Adds `lhs` and `rhs`.
public func + <T: IntegerArithmetic>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value + rhs.value)
}

/// Adds `lhs` and `rhs`.
public func + <T: IntegerArithmetic>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value + rhs)
}

/// Adds `lhs` and `rhs`.
public func + <T: IntegerArithmetic>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs + rhs.value)
}

/// Subtracts `lhs` and `rhs`.
public func - <T: IntegerArithmetic>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value - rhs.value)
}

/// Subtracts `lhs` and `rhs`.
public func - <T: IntegerArithmetic>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value - rhs)
}

/// Subtracts `lhs` and `rhs`.
public func - <T: IntegerArithmetic>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs - rhs.value)
}

/// Multiplies `lhs` and `rhs`.
public func * <T: IntegerArithmetic>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value * rhs.value)
}

/// Multiplies `lhs` and `rhs`.
public func * <T: IntegerArithmetic>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value * rhs)
}

/// Multiplies `lhs` and `rhs`.
public func * <T: IntegerArithmetic>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs * rhs.value)
}

/// Divides `lhs` and `rhs`.
public func / <T: IntegerArithmetic>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value / rhs.value)
}

/// Divides `lhs` and `rhs`.
public func / <T: IntegerArithmetic>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value / rhs)
}

/// Divides `lhs` and `rhs`.
public func / <T: IntegerArithmetic>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs / rhs.value)
}

/// Divides `lhs` and `rhs`.
public func % <T: IntegerArithmetic>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value % rhs.value)
}

/// Divides `lhs` and `rhs`.
public func % <T: IntegerArithmetic>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value % rhs)
}

/// Divides `lhs` and `rhs`.
public func % <T: IntegerArithmetic>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs % rhs.value)
}

/// Returns the intersection of bits set in the two arguments.
///
/// - Complexity: O(1).
public func & <T: BitwiseOperations>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value & rhs.value)
}

/// Returns the intersection of bits set in the two arguments.
///
/// - Complexity: O(1).
public func & <T: BitwiseOperations>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value & rhs)
}

/// Returns the intersection of bits set in the two arguments.
///
/// - Complexity: O(1).
public func & <T: BitwiseOperations>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs & rhs.value)
}

/// Returns the union of bits set in the two arguments.
///
/// - Complexity: O(1).
public func | <T: BitwiseOperations>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value | rhs.value)
}

/// Returns the union of bits set in the two arguments.
///
/// - Complexity: O(1).
public func | <T: BitwiseOperations>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value | rhs)
}

/// Returns the union of bits set in the two arguments.
///
/// - Complexity: O(1).
public func | <T: BitwiseOperations>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs | rhs.value)
}

/// Returns the bits that are set in exactly one of the two arguments.
///
/// - Complexity: O(1).
public func ^ <T: BitwiseOperations>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value ^ rhs.value)
}

/// Returns the bits that are set in exactly one of the two arguments.
///
/// - Complexity: O(1).
public func ^ <T: BitwiseOperations>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value ^ rhs)
}

/// Returns the bits that are set in exactly one of the two arguments.
///
/// - Complexity: O(1).
public func ^ <T: BitwiseOperations>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs ^ rhs.value)
}

/// Returns the inverse of the bits set in the argument.
///
/// - Complexity: O(1).
public prefix func ~ <T: BitwiseOperations>(x: Lazy<T>) -> Lazy<T> {
    return Lazy(~x.value)
}

#else

/// Adds `lhs` and `rhs`.
@warn_unused_result
public func + <T: IntegerArithmeticType>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value + rhs.value)
}

/// Adds `lhs` and `rhs`.
@warn_unused_result
public func + <T: IntegerArithmeticType>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value + rhs)
}

/// Adds `lhs` and `rhs`.
@warn_unused_result
public func + <T: IntegerArithmeticType>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs + rhs.value)
}

/// Subtracts `lhs` and `rhs`.
@warn_unused_result
public func - <T: IntegerArithmeticType>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value - rhs.value)
}

/// Subtracts `lhs` and `rhs`.
@warn_unused_result
public func - <T: IntegerArithmeticType>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value - rhs)
}

/// Subtracts `lhs` and `rhs`.
@warn_unused_result
public func - <T: IntegerArithmeticType>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs - rhs.value)
}

/// Multiplies `lhs` and `rhs`.
@warn_unused_result
public func * <T: IntegerArithmeticType>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value * rhs.value)
}

/// Multiplies `lhs` and `rhs`.
@warn_unused_result
public func * <T: IntegerArithmeticType>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value * rhs)
}

/// Multiplies `lhs` and `rhs`.
@warn_unused_result
public func * <T: IntegerArithmeticType>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs * rhs.value)
}

/// Divides `lhs` and `rhs`.
@warn_unused_result
public func / <T: IntegerArithmeticType>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value / rhs.value)
}

/// Divides `lhs` and `rhs`.
@warn_unused_result
public func / <T: IntegerArithmeticType>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value / rhs)
}

/// Divides `lhs` and `rhs`.
@warn_unused_result
public func / <T: IntegerArithmeticType>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs / rhs.value)
}

/// Divides `lhs` and `rhs`.
@warn_unused_result
public func % <T: IntegerArithmeticType>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value % rhs.value)
}

/// Divides `lhs` and `rhs`.
@warn_unused_result
public func % <T: IntegerArithmeticType>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value % rhs)
}

/// Divides `lhs` and `rhs`.
@warn_unused_result
public func % <T: IntegerArithmeticType>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs % rhs.value)
}

/// Returns the intersection of bits set in `lhs` and `rhs`.
///
/// - Complexity: O(1).
@warn_unused_result
public func & <T: BitwiseOperationsType>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value & rhs.value)
}

/// Returns the intersection of bits set in `lhs` and `rhs`.
///
/// - Complexity: O(1).
@warn_unused_result
public func & <T: BitwiseOperationsType>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value & rhs)
}

/// Returns the intersection of bits set in `lhs` and `rhs`.
///
/// - Complexity: O(1).
@warn_unused_result
public func & <T: BitwiseOperationsType>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs & rhs.value)
}

/// Returns the union of bits set in `lhs` and `rhs`.
///
/// - Complexity: O(1).
@warn_unused_result
public func | <T: BitwiseOperationsType>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value | rhs.value)
}

/// Returns the union of bits set in `lhs` and `rhs`.
///
/// - Complexity: O(1).
@warn_unused_result
public func | <T: BitwiseOperationsType>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value | rhs)
}

/// Returns the union of bits set in `lhs` and `rhs`.
///
/// - Complexity: O(1).
@warn_unused_result
public func | <T: BitwiseOperationsType>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs | rhs.value)
}

/// Returns the bits that are set in exactly one of `lhs` and `rhs`.
///
/// - Complexity: O(1).
@warn_unused_result
public func ^ <T: BitwiseOperationsType>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value ^ rhs.value)
}

/// Returns the bits that are set in exactly one of `lhs` and `rhs`.
///
/// - Complexity: O(1).
@warn_unused_result
public func ^ <T: BitwiseOperationsType>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value ^ rhs)
}

/// Returns the bits that are set in exactly one of `lhs` and `rhs`.
///
/// - Complexity: O(1).
@warn_unused_result
public func ^ <T: BitwiseOperationsType>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs ^ rhs.value)
}

/// Returns `x ^ ~Self.allZeros`.
///
/// - Complexity: O(1).
@warn_unused_result
public prefix func ~ <T: BitwiseOperationsType>(x: Lazy<T>) -> Lazy<T> {
    return Lazy(~x.value)
}

#endif
