//
//  GenericCoreDataStack.swift
//  Pods
//
//  Created by Tony Stone on 1/6/16.
//
//

import Foundation
import CoreData
import TraceLog

public typealias ConfigurationOptionsType = [String : (storeType: String, storeOptions: [NSObject : AnyObject]?, migrationManager: NSMigrationManager?)]

internal let defaultModelConfigurationName: String = "Default"

internal let storeOptionsDefault: [NSObject : AnyObject] = [
    NSIgnorePersistentStoreVersioningOption         : true,
    NSMigratePersistentStoresAutomaticallyOption    : true,
    NSInferMappingModelAutomaticallyOption          : true,
    NSPersistentStoreFileProtectionKey              : NSFileProtectionComplete
]

public let configurationOptionsDefault: ConfigurationOptionsType = [defaultModelConfigurationName : (storeType: NSSQLiteStoreType, storeOptions: nil, migrationManager: nil)]

/**
    A Core Data stack that can be customized with specific NSPersistentStoreCoordinator and a NSManagedObjectContext Context type.
 */
public class GenericCoreDataStack<CoordinatorType: NSPersistentStoreCoordinator, ContextType: NSManagedObjectContext> {
    
    private let managedObjectModel: NSManagedObjectModel
    private let persistentStoreCoordinator: CoordinatorType
    private let tag: String
    
    // We allow access to the mainThreadContext
    private let mainContext: ContextType
    
    /**
        Initializes the receiver with a managed object model.
     
        - Parameter managedObjectModel: A managed object model.
        - configurationOptions: Optional configuration settings by persistent store config name (see ConfigurationOptionsType for structure)
        - namingPrefix: An optional String which is appended to the beginning of the persistent store names.
        - logTag: An optional String that will be used as the tag for logging (default is GenericCoreDataStack).  This is typically used if you are embedding GenericCoreDataStack in something else and you want to to log as your class.
     */
    public init?(managedObjectModel model: NSManagedObjectModel, configurationOptions options: ConfigurationOptionsType = configurationOptionsDefault, namingPrefix prefix: String = "cache", logTag tag: String = String(GenericCoreDataStack.self)) {
        
        self.managedObjectModel = model
        self.tag = tag
        
        // Create the coordinator
        persistentStoreCoordinator = CoordinatorType(managedObjectModel: managedObjectModel)
        
        // Now the main thread context
        mainContext = ContextType(concurrencyType: .MainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        do {
            //
            // Figure out where to put things
            //
            // Note: We use the applications bundle not the classes or modules.
            //
            let cachesURL = try NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
            
            logInfo(tag) { "Store path: \(cachesURL.path ?? "Unknown")" }
            
            let configurations = managedObjectModel.configurations
            
            // There is only one so it's the default configuration
            if configurations.count == 1 {
                
                let storeURL = cachesURL.URLByAppendingPathComponent("\(prefix)\(managedObjectModel.uniqueIdentifier())default.sqlite")
                
                if let (storeType, storeOptions, migrationManager) = options[defaultModelConfigurationName] {
                    try self.addPersistentStore(storeType, configuration: nil, URL: storeURL, options: storeOptions, migrationManger: migrationManager)
                } else {
                    try self.addPersistentStore(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, migrationManger: nil)
                }
            } else {
                for configuration in configurations {
                    
                    if configuration != defaultModelConfigurationName {
                        
                        let storeURL = cachesURL.URLByAppendingPathComponent("\(prefix)\(managedObjectModel.uniqueIdentifier())\(configuration).sqlite")
                        
                        if let (storeType, storeOptions, migrationManager) = options[configuration] {
                            try self.addPersistentStore(storeType, configuration: configuration, URL: storeURL, options: storeOptions, migrationManger: migrationManager)
                        } else {
                            try self.addPersistentStore(NSSQLiteStoreType, configuration: configuration, URL: storeURL, options: nil, migrationManger: nil)
                        }
                    }
                }
            }
            
        } catch  let error as NSError {
            
            logError(tag) {
                "Failed to initialize: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    public func mainThreadContext () -> NSManagedObjectContext {
        return mainContext
    }
    
    public func editContext () -> NSManagedObjectContext {
        
        logInfo(tag) { "Creating edit context for \(NSThread .currentThread())..." }
        
        let context = ContextType(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        context.parentContext = mainContext
        
        logInfo(tag) { "Edit context created." }
        
        return context
    }
    
    private func addPersistentStore(storeType: String, configuration: String?, URL storeURL: NSURL, options: [NSObject : AnyObject]?, migrationManger migrator: NSMigrationManager?) throws {
        
        do {
            //
            // If a migration manager was supplied, try a migration first.
            //
            if let migrationManager = migrator {
                
                if let mappingModel = NSMappingModel(fromBundles: nil, forSourceModel: migrationManager.sourceModel, destinationModel: migrationManager.destinationModel) {
                    
                    // TODO: Rename old file first
                    try migrationManager.migrateStoreFromURL(storeURL, type: storeType, options: options, withMappingModel: mappingModel, toDestinationURL: storeURL, destinationType: storeType, destinationOptions: options)
                }
            }
            
            logInfo(tag) {
                "Attaching persistent store \"\(storeURL.lastPathComponent ?? "Unknown")\" for type: \(persistentStoreType)."
            }
            try persistentStoreCoordinator.addPersistentStoreWithType(storeType, configuration:  configuration, URL: storeURL, options: options)
            
            logInfo(tag) {
                "Persistent store attached successfully."
            }
            
        } catch let error as NSError where [NSMigrationError,
            NSMigrationConstraintViolationError,
            NSMigrationCancelledError,
            NSMigrationMissingSourceModelError,
            NSMigrationMissingMappingModelError,
            NSMigrationManagerSourceStoreError,
            NSMigrationManagerDestinationStoreError].contains(error.code) {
                
                logError { "Migration failed due to error: \(error.localizedDescription)" }
                
                throw error
        } catch let error as NSError {
            logError { "Failed to attached persistent store: \(error.localizedDescription)" }
            throw error
        }
    }
}
