//  DictionaryTests.swift
//
//  Copyright (c) 2014 - 2017 Pinglin Tang
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

import XCTest
@testable import SwiftyJSON

class DictionaryTests: XCTestCase {

    func testGetter() {
        let dictionary = ["number": 9823.212, "name": "NAME", "list": [1234, 4.212], "object": ["sub_number": 877.2323, "sub_name": "sub_name"], "bool": true] as [String: Any]
        let json = JSON(dictionary)
        //dictionary
        XCTAssertEqual((json.dictionary!["number"]! as JSON).double!, 9823.212)
        XCTAssertEqual((json.dictionary!["name"]! as JSON).string!, "NAME")
        XCTAssertEqual(((json.dictionary!["list"]! as JSON).array![0] as JSON).int!, 1234)
        XCTAssertEqual(((json.dictionary!["list"]! as JSON).array![1] as JSON).double!, 4.212)
        XCTAssertEqual((((json.dictionary!["object"]! as JSON).dictionaryValue)["sub_number"]! as JSON).double!, 877.2323)
        XCTAssertTrue(json.dictionary!["null"] == nil)
        //dictionaryValue
        XCTAssertEqual(((((json.dictionaryValue)["object"]! as JSON).dictionaryValue)["sub_name"]! as JSON).string!, "sub_name")
        XCTAssertEqual((json.dictionaryValue["bool"]! as JSON).bool!, true)
        XCTAssertTrue(json.dictionaryValue["null"] == nil)
        XCTAssertTrue(JSON.null.dictionaryValue == [:])
        //dictionaryObject
        XCTAssertEqual(json.dictionaryObject!["number"]! as? Double, 9823.212)
        XCTAssertTrue(json.dictionaryObject!["null"] == nil)
        XCTAssertTrue(JSON.null.dictionaryObject == nil)
    }

    func testSetter() {
        var json: JSON = ["test": "case"]
        XCTAssertEqual(json.dictionaryObject! as! [String: String], ["test": "case"])
        json.dictionaryObject = ["name": "NAME"]
        XCTAssertEqual(json.dictionaryObject! as! [String: String], ["name": "NAME"])
    }
    
    func testCustomRecursiveSetter() throws {
        var dict: [String: Any] = [
            "user": [
                "entities": [
                    "url": [
                        "urls": [
                            [ "url": "http://example.com", "indices": [0, 23] ]
                        ]
                    ]
                ]
            ]
        ]
    
        // top setter test
        try dict.set("newValue", at: ["a"])
        XCTAssertEqual(dict["a"] as? String, "newValue")
        
        // nested values test
        let newIndices = [5, 10]
        let path: [JSONSubscriptType] = ["user", "entities", "url", "urls", 0, "indices"]

        try dict.set(newIndices, at: path)
        let result = (((((dict["user"] as? [String: Any])?["entities"] as? [String: Any])?["url"] as? [String: Any])?["urls"] as? [[String: Any]])?[0]["indices"]) as? [Int]
        XCTAssertEqual(result, newIndices)
        
        // missing key test
        dict.removeAll()
        XCTAssertThrowsError(
            try dict.set("value", at: ["doesNotExist", "doesNotExist2"])
        ) { error in
            XCTAssertEqual(error as? SwiftyJSONError, .notExist)
        }
        
        // wrong type test
        dict = ["user": "notADictionary"]
        XCTAssertThrowsError(
            try dict.set("value", at: ["user", "entities"])
        ) { error in
            XCTAssertEqual(error as? SwiftyJSONError, .wrongType)
        }
    }
}
