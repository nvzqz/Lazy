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

    #if swift(>=3)

    fileprivate var _ref: _LazyRef<Value>

    #else

    private var _ref: _LazyRef<Value>

    #endif

    /// The value for `self`.
    ///
    /// Getting the value evaluates `self`.
    public var value: Value {
        get {
            switch _ref.option {
            case let .value(value):
                return value
            case let .closure(closure):
                let value = closure()
                _ref.option = .value(value)
                return value
            }
        }
        set {
            #if swift(>=3)
                if !isKnownUniquelyReferenced(&_ref) {

                }
            #else

            #endif
            if !isKnownUniquelyReferenced(&_ref) {
                _ref = _LazyRef(option: .value(newValue))
            } else {
                _ref.option = .value(newValue)
            }
        }
    }

    /// `true` if `self` was previously evaluated.
    public var wasEvaluated: Bool {
        return _ref.optionalValue != nil
    }

    /// A textual representation of this instance.
    public var description: String {
        return "Lazy(\(_ref.optionalValue.map(String.init(describing:)) ?? "Unevaluated"))"
    }

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return "Lazy(\(_ref.optionalValue.map(String.init(reflecting:)) ?? "Unevaluated"))"
    }

    #if swift(>=3)

    /// Create a lazy value.
    public init(_ value: @escaping @autoclosure () -> Value) {
        _ref = _LazyRef(value)
    }

    /// Maps `transform` over `value` and returns a lazy result.
    public func map<T>(_ transform: @escaping (Value) -> T) -> Lazy<T> {
        return Lazy<T>(transform(self.value))
    }

    #else

    /// Create a lazy value.
    public init(@autoclosure(escaping) _ value: () -> Value) {
        _ref = _LazyRef(value)
    }

    /// Maps `transform` over `value` and returns a lazy result.
    @warn_unused_result
    public func map<T>(transform: (Value) -> T) -> Lazy<T> {
        return Lazy<T>(transform(self.value))
    }

    #endif

    /// Evaluates `self`.
    public func evaluate() {
        if case let .closure(closure) = _ref.option {
            _ref.option = .value(closure())
        }
    }
    
}

/// Implementation detail for `Lazy<Value>`.
private final class _LazyRef<Value> {

    var option: _LazyOption<Value>

    var optionalValue: Value? {
        if case let .value(value) = option {
            return value
        } else {
            return nil
        }
    }

    #if swift(>=3)

    init(_ value: @escaping @autoclosure () -> Value) {
        option = .closure(value)
    }

    #else

    init(@autoclosure(escaping) _ value: () -> Value) {
        option = .closure(value)
    }

    #endif

    init(option: _LazyOption<Value>) {
        self.option = option
    }

}

private enum _LazyOption<Value> {

    case closure(() -> Value)

    case value(Value)

}

extension Lazy: CustomReflectable {

    private var _customMirror: Mirror {
        return Mirror(self, children: ["value": _ref.optionalValue as Any])
    }

    #if swift(>=3)

    /// The custom mirror for this instance.
    public var customMirror: Mirror {
        return _customMirror
    }

    #else

    /// Returns the `Mirror` for `self`.
    @warn_unused_result
    public func customMirror() -> Mirror {
        return _customMirror
    }

    #endif

}

extension Lazy where Value: AbsoluteValuable {

    #if swift(>=3)

    /// Returns the absolute value of `x`.
    public static func abs(_ x: Lazy) -> Lazy {
        return Lazy(Value.abs(x.value))
    }

    #else

    /// Returns the absolute value of `x`.
    @warn_unused_result
    public static func abs(x: Lazy) -> Lazy {
        return Lazy(Value.abs(x.value))
    }

    #endif

}

#if swift(>=3)
postfix operator *
postfix operator ~
#else
postfix operator ~ {}
postfix operator * {}
#endif

/// Returns the `value` of `lazy`.
public postfix func * <T>(lazy: Lazy<T>) -> T {
    return lazy.value
}

#if swift(>=3)
/// Returns a lazy value.
public postfix func ~ <T>(value: @autoclosure @escaping () -> T) -> Lazy<T> {
    return Lazy(value)
}
#else
/// Returns a lazy value.
public postfix func ~ <T>(@autoclosure(escaping) value: () -> T) -> Lazy<T> {
    return Lazy(value)
}
#endif

/// Returns a Boolean value indicating whether two values are equal.
public func == <T: Equatable>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<Bool> {
    return Lazy(lhs.value == rhs.value)
}

/// Returns a Boolean value indicating whether two values are equal.
public func == <T: Equatable>(lhs: Lazy<T>, rhs: T) -> Lazy<Bool> {
    return Lazy(lhs.value == rhs)
}

/// Returns a Boolean value indicating whether two values are equal.
public func == <T: Equatable>(lhs: T, rhs: Lazy<T>) -> Lazy<Bool> {
    return Lazy(lhs == rhs.value)
}

/// Returns a Boolean value indicating whether two values are equal.
public func == <T: Equatable>(lhs: Lazy<T?>, rhs: Lazy<T?>) -> Lazy<Bool> {
    return Lazy(lhs.value == rhs.value)
}

/// Returns a Boolean value indicating whether two values are equal.
public func == <T: Equatable>(lhs: Lazy<T?>, rhs: T?) -> Lazy<Bool> {
    return Lazy(lhs.value == rhs)
}

/// Returns a Boolean value indicating whether two values are equal.
public func == <T: Equatable>(lhs: T?, rhs: Lazy<T?>) -> Lazy<Bool> {
    return Lazy(lhs == rhs.value)
}

#if !swift(>=3)

/// Returns a Boolean value indicating whether two values are equal.
@warn_unused_result
public func == <T: Equatable>(lhs: Lazy<T!>, rhs: Lazy<T!>) -> Lazy<Bool> {
    return Lazy(lhs.value == rhs.value)
}

/// Returns a Boolean value indicating whether two values are equal.
@warn_unused_result
public func == <T: Equatable>(lhs: Lazy<T!>, rhs: T!) -> Lazy<Bool> {
    return Lazy(lhs.value == rhs)
}

/// Returns a Boolean value indicating whether two values are equal.
@warn_unused_result
public func == <T: Equatable>(lhs: T!, rhs: Lazy<T!>) -> Lazy<Bool> {
    return Lazy(lhs == rhs.value)
}

#endif

/// Returns a Boolean value indicating whether two values are not equal.
public func != <T: Equatable>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<Bool> {
    return Lazy(lhs.value != rhs.value)
}

/// Returns a Boolean value indicating whether two values are not equal.
public func != <T: Equatable>(lhs: Lazy<T>, rhs: T) -> Lazy<Bool> {
    return Lazy(lhs.value != rhs)
}

/// Returns a Boolean value indicating whether two values are not equal.
public func != <T: Equatable>(lhs: T, rhs: Lazy<T>) -> Lazy<Bool> {
    return Lazy(lhs != rhs.value)
}

/// Returns a Boolean value indicating whether two values are not equal.
public func != <T: Equatable>(lhs: Lazy<T?>, rhs: Lazy<T?>) -> Lazy<Bool> {
    return Lazy(lhs.value != rhs.value)
}

/// Returns a Boolean value indicating whether two values are not equal.
public func != <T: Equatable>(lhs: Lazy<T?>, rhs: T?) -> Lazy<Bool> {
    return Lazy(lhs.value != rhs)
}

/// Returns a Boolean value indicating whether two values are not equal.
public func != <T: Equatable>(lhs: T?, rhs: Lazy<T?>) -> Lazy<Bool> {
    return Lazy(lhs != rhs.value)
}

#if !swift(>=3)

/// Returns a Boolean value indicating whether two values are not equal.
@warn_unused_result
public func != <T: Equatable>(lhs: Lazy<T!>, rhs: Lazy<T!>) -> Lazy<Bool> {
    return Lazy(lhs.value != rhs.value)
}

/// Returns a Boolean value indicating whether two values are not equal.
@warn_unused_result
public func != <T: Equatable>(lhs: Lazy<T!>, rhs: T!) -> Lazy<Bool> {
    return Lazy(lhs.value != rhs)
}

/// Returns a Boolean value indicating whether two values are not equal.
@warn_unused_result
public func != <T: Equatable>(lhs: T!, rhs: Lazy<T!>) -> Lazy<Bool> {
    return Lazy(lhs != rhs.value)
}

#endif

#if swift(>=3)

/// Subtracts `lhs` and `rhs`.
public func - <T: SignedNumber>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value - rhs.value)
}

/// Subtracts `lhs` and `rhs`.
public func - <T: SignedNumber>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value - rhs)
}

/// Subtracts `lhs` and `rhs`.
public func - <T: SignedNumber>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs - rhs.value)
}

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

/// Divides `lhs` and `rhs`, returning the remainder.
public func % <T: IntegerArithmetic>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value % rhs.value)
}

/// Divides `lhs` and `rhs`, returning the remainder.
public func % <T: IntegerArithmetic>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value % rhs)
}

/// Divides `lhs` and `rhs`, returning the remainder.
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

/// Subtracts `lhs` and `rhs`.
@warn_unused_result
public func - <T: SignedNumberType>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value - rhs.value)
}

/// Subtracts `lhs` and `rhs`.
@warn_unused_result
public func - <T: SignedNumberType>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value - rhs)
}

/// Subtracts `lhs` and `rhs`.
@warn_unused_result
public func - <T: SignedNumberType>(lhs: T, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs - rhs.value)
}

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

/// Divides `lhs` and `rhs`, returning the remainder.
@warn_unused_result
public func % <T: IntegerArithmeticType>(lhs: Lazy<T>, rhs: Lazy<T>) -> Lazy<T> {
    return Lazy(lhs.value % rhs.value)
}

/// Divides `lhs` and `rhs`, returning the remainder.
@warn_unused_result
public func % <T: IntegerArithmeticType>(lhs: Lazy<T>, rhs: T) -> Lazy<T> {
    return Lazy(lhs.value % rhs)
}

/// Divides `lhs` and `rhs`, returning the remainder.
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

/// Adds `lhs` and `rhs`.
public func + (lhs: Lazy<Double>, rhs: Lazy<Double>) -> Lazy<Double> {
    return Lazy(lhs.value + rhs.value)
}

/// Adds `lhs` and `rhs`.
public func + (lhs: Lazy<Double>, rhs: Double) -> Lazy<Double> {
    return Lazy(lhs.value + rhs)
}

/// Adds `lhs` and `rhs`.
public func + (lhs: Double, rhs: Lazy<Double>) -> Lazy<Double> {
    return Lazy(lhs + rhs.value)
}

/// Subtracts `lhs` and `rhs`.
public func - (lhs: Lazy<Double>, rhs: Lazy<Double>) -> Lazy<Double> {
    return Lazy(lhs.value - rhs.value)
}

/// Subtracts `lhs` and `rhs`.
public func - (lhs: Lazy<Double>, rhs: Double) -> Lazy<Double> {
    return Lazy(lhs.value - rhs)
}

/// Subtracts `lhs` and `rhs`.
public func - (lhs: Double, rhs: Lazy<Double>) -> Lazy<Double> {
    return Lazy(lhs - rhs.value)
}

/// Multiplies `lhs` and `rhs`.
public func * (lhs: Lazy<Double>, rhs: Lazy<Double>) -> Lazy<Double> {
    return Lazy(lhs.value * rhs.value)
}

/// Multiplies `lhs` and `rhs`.
public func * (lhs: Lazy<Double>, rhs: Double) -> Lazy<Double> {
    return Lazy(lhs.value * rhs)
}

/// Multiplies `lhs` and `rhs`.
public func * (lhs: Double, rhs: Lazy<Double>) -> Lazy<Double> {
    return Lazy(lhs * rhs.value)
}

/// Divides `lhs` and `rhs`.
public func / (lhs: Lazy<Double>, rhs: Lazy<Double>) -> Lazy<Double> {
    return Lazy(lhs.value / rhs.value)
}

/// Divides `lhs` and `rhs`.
public func / (lhs: Lazy<Double>, rhs: Double) -> Lazy<Double> {
    return Lazy(lhs.value / rhs)
}

/// Divides `lhs` and `rhs`.
public func / (lhs: Double, rhs: Lazy<Double>) -> Lazy<Double> {
    return Lazy(lhs / rhs.value)
}

/// Adds `lhs` and `rhs`.
public func + (lhs: Lazy<Float>, rhs: Lazy<Float>) -> Lazy<Float> {
    return Lazy(lhs.value + rhs.value)
}

/// Adds `lhs` and `rhs`.
public func + (lhs: Lazy<Float>, rhs: Float) -> Lazy<Float> {
    return Lazy(lhs.value + rhs)
}

/// Adds `lhs` and `rhs`.
public func + (lhs: Float, rhs: Lazy<Float>) -> Lazy<Float> {
    return Lazy(lhs + rhs.value)
}

/// Subtracts `lhs` and `rhs`.
public func - (lhs: Lazy<Float>, rhs: Lazy<Float>) -> Lazy<Float> {
    return Lazy(lhs.value - rhs.value)
}

/// Subtracts `lhs` and `rhs`.
public func - (lhs: Lazy<Float>, rhs: Float) -> Lazy<Float> {
    return Lazy(lhs.value - rhs)
}

/// Subtracts `lhs` and `rhs`.
public func - (lhs: Float, rhs: Lazy<Float>) -> Lazy<Float> {
    return Lazy(lhs - rhs.value)
}

/// Multiplies `lhs` and `rhs`.
public func * (lhs: Lazy<Float>, rhs: Lazy<Float>) -> Lazy<Float> {
    return Lazy(lhs.value * rhs.value)
}

/// Multiplies `lhs` and `rhs`.
public func * (lhs: Lazy<Float>, rhs: Float) -> Lazy<Float> {
    return Lazy(lhs.value * rhs)
}

/// Multiplies `lhs` and `rhs`.
public func * (lhs: Float, rhs: Lazy<Float>) -> Lazy<Float> {
    return Lazy(lhs * rhs.value)
}

/// Divides `lhs` and `rhs`.
public func / (lhs: Lazy<Float>, rhs: Lazy<Float>) -> Lazy<Float> {
    return Lazy(lhs.value / rhs.value)
}

/// Divides `lhs` and `rhs`.
public func / (lhs: Lazy<Float>, rhs: Float) -> Lazy<Float> {
    return Lazy(lhs.value / rhs)
}

/// Divides `lhs` and `rhs`.
public func / (lhs: Float, rhs: Lazy<Float>) -> Lazy<Float> {
    return Lazy(lhs / rhs.value)
}
