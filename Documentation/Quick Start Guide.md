# Coherence
## Quick Start Guide

Coherence is designed to be very easy to get started with.  If your only requirements are to load a data model using the default options for the store, it's as simple as the following:

```swift
let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: "ModelName")

try connect.start()
```

This will create an instance of `GenericConnect`, search for the model in the application bundle, loads the model and creates a persistent store in the default location. At this point you have a fully initialized CoreData stack to work with, all CoreData and `Connect` services are ready.

>**Tip:** The `"let connect"` declaration above specifically declares it's type as the `Connect` protocol, this is done to avoid specifying the generic arguments for instance variables that hold a connect instance.  This allows you to change the `ContextStrategy` or even the Connect class type without changing any declarations you may have in your code.  All that is needed to to change the instantiation of the instance. Although this is not specifically required, it is advised that you follow this same convention.

Should you require asynchronous startup, connect also supplies an async version of the `start` method.  All you need to do is supply a block to handle any errors that are encountered while starting.  In the example below, we use the async version.

```swift
try connect.start { (error) in
    // Your callback code
}
```


### Where to initialize and start

The `Connect` instance can be stored in your `AppDelegate` and injected throughout the application to gain access to the services that Coherence offers.  In the following code block, we do just that and also start the instance within the `application(_:didFinishLaunchingWithOptions:)`.  This is a common place to start the instance but it can be started in any location you desire. 

```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: "ModelName")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        do {
            try self.connect.start()

        } catch {
            fatalError("\(error)")
        }
        return true
    }
}
```

Coherence does not enforce any constraints as to where you initialize or start it's instances but understand that until the `Connect` instance has been started, database operation and other services `Connect` offers are not available (this includes your CoreData stack.)
