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
public struct Lazy<Value>: CustomStringConvertible {

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
                _ref = _LazyRef(newValue)
            } else {
                _ref.value = newValue
            }
        }
    }

    /// A textual representation of this instance.
    public var description: String {
        return "Lazy(\(_ref.value.map(String.init(_:)) ?? "Uninitialized"))"
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

}
