///
///  ConfigurationTests.swift
///
///  Copyright 2016 The Climate Corporation
///  Copyright 2016 Tony Stone
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
///  Created by Tony Stone on 6/22/15.
///
import XCTest

@testable import Coherence

typealias Char = Int8

let charPListTestValue: Character       = "A"
let boolPListTestValue: Bool            = true

let integerPListTestValue: Int          = 12345
let unsignedIntegerPListTestValue: UInt = 12345
let floatPListTestValue: Float          = 12345.67
let doublePListTestValue: Double        = 12345.67
let stringPListTestValue: String        = "String test value"

let charTestValue: Character            = "b"
let boolTestValue: Bool                 = true

let integerTestValue: Int               = 54321
let unsignedIntegerTestValue: UInt      = 54321
let floatTestValue: Float               = 54321.67
let doubleTestValue: Double             = 54321.67
let stringTestValue: String             = "String test value 2"
let stringReadonlyTestValue: String     = "Readonly string test value"
let intReadonlyTestValue: Int           = 1

@objc
private protocol MockSimpleProtocol: NSObjectProtocol {
    var string: String? { get set }
}

@objc
private class MockSimpleObject: NSObject, MockSimpleProtocol {
    internal var string: String? = nil
}

//
// Test configuration when developers are using a pure protocol
// for their configuration construction.
//
@objc
internal
protocol TestPureProtocolConfiguration : NSObjectProtocol {

//    var charProperty: Character      { get set }
    var boolProperty: Bool      { get set }

    var integerProperty: Int    { get set }
    var unsignedIntegerProperty: UInt { get set }

    var floatProperty: Float    { get set }
    var doubleProperty: Double  { get set }

    var stringProperty: String  {get set }
}

//
// Test configuration when developers are using a subclass
// of CCConfiguration for their configuration using default values.
@objc
internal
protocol TestSubClassConfiguration  : NSObjectProtocol {
    
    //    var charProperty: Character      { get set }
    var boolProperty: Bool      { get set }
    
    var integerProperty: Int    { get set }
    var unsignedIntegerProperty: UInt { get set }
    
    var floatProperty: Float    { get set }
    var doubleProperty: Double  { get set }
    
    var stringProperty: String  {get set }
    
    var stringPropertyReadonly: String { get }
    var intPropertyReadonly: Int  { get }
}

class TestSubClassConfigurationClass : Configuration<TestSubClassConfiguration> {
    
    override class func defaults () -> [String : AnyObject] {
        return ["stringPropertyReadonly" : stringReadonlyTestValue as AnyObject, "intPropertyReadonly": intReadonlyTestValue as AnyObject]
    }
}

class ConfigurationTests : XCTestCase {
    
    func testPureProtocolConfigurationConstruction() {
        
        XCTAssertNotNil(Configuration<TestPureProtocolConfiguration>.instance())
    }
    
    func testPureProtocolConfigurationCRUD() {
        
        let configuration = Configuration<TestPureProtocolConfiguration>.instance()

        // Note all values are filled with the values from the info.plist
        //        XCTAssertEqual       (configuration.charProperty, charPListTestValue)
        XCTAssertEqual       (configuration.boolProperty, boolPListTestValue)
        
        XCTAssertEqual       (configuration.integerProperty,         integerPListTestValue)
        XCTAssertEqual       (configuration.unsignedIntegerProperty, unsignedIntegerPListTestValue)
        
        XCTAssertEqual       (configuration.floatProperty,  floatPListTestValue)
        XCTAssertEqual       (configuration.doubleProperty, doublePListTestValue)
        
        XCTAssertEqual       (configuration.stringProperty, stringPListTestValue)
    }

    func testSubclassConfigurationConstruction () {
        
        XCTAssertNotNil(TestSubClassConfigurationClass.instance())
    }
    
    func testSubclassConfigurationCRUD() {
        
        let configuration: TestSubClassConfiguration = TestSubClassConfigurationClass.instance()
        
        // Note all values are filled with the values from the info.plist
        //        XCTAssertEqual       (configuration.charProperty, charPListTestValue)
        XCTAssertEqual       (configuration.boolProperty, boolPListTestValue)
        
        XCTAssertEqual       (configuration.integerProperty,         integerPListTestValue)
        XCTAssertEqual       (configuration.unsignedIntegerProperty, unsignedIntegerPListTestValue)
        
        XCTAssertEqual       (configuration.floatProperty,  floatPListTestValue)
        XCTAssertEqual       (configuration.doubleProperty, doublePListTestValue)
        
        XCTAssertEqual       (configuration.stringProperty, stringPListTestValue)
        
        XCTAssertEqual       (configuration.stringPropertyReadonly,  stringReadonlyTestValue)
        XCTAssertEqual       (configuration.intPropertyReadonly,   intReadonlyTestValue)
    }

    func testLoadObject() {

        let input = ["string": "Test string 1"]
        let expected: String? = "Test string 1"

        let object = MockSimpleObject()

        do {
            try loadObject(for: MockSimpleProtocol.self, anObject: object, bundleKey: "CCCustomConfiguration", defaults: input)

            XCTAssertEqual(object.string, expected)
        } catch {
            XCTFail("\(error.localizedDescription)")
        }
    }

    func testLoadObjectMissingBundleKey() {

        let input = ["string": "Test string 1"]
        let expected = "Error(s) loading protocol.\r" +
                       "\tBundle key \"MissingKey\" missing from Info.plist file or is an invalid type.  The type must be a dictionary."

        let object = MockSimpleObject()
        XCTAssertThrowsError(try loadObject(for: MockSimpleProtocol.self, anObject: object, bundleKey: "MissingKey", defaults: input)) { (error) in

            if case ConfigurationErrors.failedInitialization(let message) = error {
                XCTAssertEqual(message, expected)
            } else {
                XCTFail("Wrong error thrown: \(error) is not equal to \(expected)")
            }
        }
    }

    func testLoadObjectMissingSetting() {

        let input: [String: String] = [:]
        let expected = "Error(s) loading protocol.\r" +
        "\tKey \"string\" missing from Info.plist and no default was supplied, a value is required."

        let object = MockSimpleObject()
        XCTAssertThrowsError(try loadObject(for: MockSimpleProtocol.self, anObject: object, bundleKey: "CCCustomConfiguration", defaults: input)) { (error) in

            if case ConfigurationErrors.failedInitialization(let message) = error {
                XCTAssertEqual(message, expected)
            } else {
                XCTFail("Wrong error thrown: \(error) is not equal to \(expected)")
            }
        }
    }
}
