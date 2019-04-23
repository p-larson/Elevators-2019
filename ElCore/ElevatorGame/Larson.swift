//
//  Larson.swift
//  ElCore
//
//  Created by Peter Larson on 3/12/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation

public struct Larson {
    
    public static var debugging: Bool = false
    public static var timing: Bool = true
    
    private static var function: [String]? = nil
    
    private static let tab = "\t", line = "\n", open = "+", close = "-"
    
    private static var space: String { return String(repeating: " ", count: function?.count ?? 0)}
    
    public static func enterFunction(_ label: String) {
        guard debugging else {
            return
        }
        
        if function == nil {
            function = [label]
        } else {
            function?.append(label)
        }
        
        print(time + space + label + open)
    }
    
    private static let format: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()
    
    private static var time: String {
        return (timing ? "[\(format.string(from: Date()))] ":"")
    }
    
    public static func exitFunction() {
        guard debugging, let function = function?.popLast() else {
            return
        }
        
        print(time + space + close, function, line)
    }
    
    /// Debug will print items if Larson.debugging is enabled
    ///
    /// - Parameter items: Debug
    public static func debug(_ items: Any...) {
        guard debugging else {
            return
        }
        if function != nil {
            print(time, space, items)
        } else {
            print(time, items)
        }
    }
    
    static func perform(_ block: @escaping () -> ()) {
        block()
    }
    
    static func newline() {
        print(line)
    }
}

public let larsondebug      = Larson.debug
public let larsonenter      = Larson.enterFunction
public let larsonexit       = Larson.exitFunction
public let larsonperform    = Larson.perform
public let larsonnewline    = Larson.newline

public typealias Block = () -> ()

/*
 
 😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂
 😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂
 😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂
 😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😭😂😂😂😂😂
 😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂
 😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂
 😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂
 😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂
 😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂
 😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂
 😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂
 😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂😂
 
 */
