# Lazy

Save the hard work for later.

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
