///
///  ContextStrategy.swift
///
///  Copyright 2017 Tony Stone
///
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
///
///  Created by Tony Stone on 3/29/17.
///
import Swift
import CoreData

///
/// A type that defines an interface for a ManagedObjectContext strategy.  This defines the hierarchy of
/// the contexts and determines how they are kept up to date when changes are made in contexts.
///
public protocol ContextStrategyType {

    ///
    /// Required initializer for all `ContextStrategyType`s.
    ///
    /// - Parameters:
    ///     - persistentStoreCoordinator: The `NSPersistentStoreCoordinator` used by this `ContextStrategy`.
    ///     - errorHandler: An error handler block call in the event a background propagation of changes fails.
    ///
    init(persistentStoreCoordinator: NSPersistentStoreCoordinator, errorHandler: @escaping AsyncErrorHandlerBlock)

    ///
    /// The main context.
    ///
    /// This context should be used for read operations only.  Use it for all fetches and NSFetchedResultsControllers.
    ///
    var viewContext: NSManagedObjectContext { get }

    ///
    /// Gets a new `BackgroundContext` that can be used for updating objects.
    ///
    /// - Note: This method and the returned `BackgroundContext` can be used on a background thread.  It can also be used on the main thread.
    ///
    func newBackgroundContext<T: BackgroundContext>() -> T
}

///
/// Base class to implement `ContextStrategyType` classes.
///
/// - Note: Subclassing notes, you can subclass this class and implement `ContextStrategyType` in order
///         to create your own Strategies.
///
open class ContextStrategy {

    internal let errorHandler: AsyncErrorHandlerBlock
    internal let persistentStoreCoordinator: NSPersistentStoreCoordinator

    public required init(persistentStoreCoordinator: NSPersistentStoreCoordinator, errorHandler: @escaping AsyncErrorHandlerBlock) {

        self.persistentStoreCoordinator = persistentStoreCoordinator
        self.errorHandler = errorHandler
    }
}
