///
///  BackgroundContext.swift
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
///  Created by Tony Stone on 4/2/17.
///
import CoreData

///
/// A NSManagedObjectContext subclass returned by all `newBackgroundContext` methods.
///
public class BackgroundContext: NSManagedObjectContext {

    internal var deinitBlock: (() -> Void)? = nil

    public override required init(concurrencyType ct: NSManagedObjectContextConcurrencyType) {
        /// Since deinit was implemented, the override constructors also must be implemented.
        super.init(concurrencyType: ct)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        self.deinitBlock?()
    }
}

