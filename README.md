# Lazy

[![Swift 2.2 | 3.0](https://img.shields.io/badge/swift-2.2%20%7C%203.0-orange.svg)](https://developer.apple.com/swift/)
![Platforms](https://img.shields.io/badge/platform-ios%20%7C%20macos%20%7C%20watchos%20%7C%20tvos%20%7C%20linux-lightgrey.svg)
[![CocoaPods](https://img.shields.io/cocoapods/v/Lazy.svg)](https://cocoapods.org/pods/Lazy)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-orange.svg)](https://swift.org/package-manager/)
[![MIT License](https://img.shields.io/badge/license-MIT-000000.svg)](https://opensource.org/licenses/MIT)

Save the hard work for later.

## The Problem

Swift allows for lazy variables out-of-the-box, however they're fairly restricted.

1. They're only available within a type definition and require a default value
that relies on limited surrounding context.

2. They can't be referenced from within `let` constant struct instances.

Lazy solves these two problems by giving you full control over how *you* want to
be lazy. For example, you can declare a `Lazy` instance *anywhere*, regardless
of scope. You can also use a `Lazy` value within any type, regardless of
instances being constants or not.

## Installation

### Compatibility

- Platforms:
    - macOS 10.9+
    - iOS 8.0+
    - watchOS 2.0+
    - tvOS 9.0+
    - Linux
- Xcode 7.3 and 8.0
- Swift 2.2 and 3.0

### Install Using Swift Package Manager
The [Swift Package Manager](https://swift.org/package-manager/) is a
decentralized dependency manager for Swift.

1. Add the project to your `Package.swift`.

    ```swift
    import PackageDescription

    let package = Package(
        name: "MyAwesomeProject",
        dependencies: [
            .Package(url: "https://github.com/nvzqz/Lazy.git",
                     majorVersion: 1)
        ]
    )
    ```

2. Import the Lazy module.

    ```swift
    import Lazy
    ```

### Install Using CocoaPods
[CocoaPods](https://cocoapods.org/) is a centralized dependency manager for
Objective-C and Swift. Go [here](https://guides.cocoapods.org/using/index.html)
to learn more.

1. Add the project to your [Podfile](https://guides.cocoapods.org/using/the-podfile.html).

    ```ruby
    use_frameworks!

    pod 'Lazy', '~> 1.0.0'
    ```

    If you want to be on the bleeding edge, replace the last line with:

    ```ruby
    pod 'Lazy', :git => 'https://github.com/nvzqz/Lazy.git'
    ```

2. Run `pod install` and open the `.xcworkspace` file to launch Xcode.

3. Import the Lazy framework.

    ```swift
    import Lazy
    ```

### Install Using Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency
manager for Objective-C and Swift.

1. Add the project to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

    ```
    github "nvzqz/Lazy"
    ```

2. Run `carthage update` and follow [the additional steps](https://github.com/Carthage/Carthage#getting-started)
   in order to add Lazy to your project.

3. Import the Lazy framework.

    ```swift
    import Lazy
    ```

### Install Manually

Simply add the `Lazy.swift` file into your project.

## Usage

### Evaluating

A lazy value is evaluated the first time its contained value is referenced.

If you need to evaluate a lazy value without getting it, you can do so with the
`evaluate()` method.

### Checking Evaluation

Not sure if a lazy value has been evaluated just yet? Simply check `wasEvaluated`!

```swift
let lazyInt = Lazy(1)
print(lazyInt.wasEvaluated)  // false
let someInt = lazyInt.value
print(lazyInt.wasEvaluated)  // true
```

### Number Operations

Lazy allows you to be very laid back with numerical operations.

```swift
let meaningOfLife = Lazy(8) * 5 + 2
let result = result.value  // 42
```

### Shorthand Operations

If you're tired of using `Lazy(...)` around your values, there's the `~` postfix
operator at your disposal.

Similar to `~`, the `*` postfix operator acts as shorthand for obtaining a
contained value.

These can be used in combination with each other for ultimate laziness:

```swift
Lazy("I should sleep in today!")*.uppercased()~  // "I SHOULD SLEEP IN TODAY!"
```

## License

Lazy is released under the [MIT License](https://opensource.org/licenses/MIT).
