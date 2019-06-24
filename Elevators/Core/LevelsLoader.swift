//
//  LevelsLoader.swift
//  Elevators
//
//  Created by Peter Larson on 6/22/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import ElCore

public class LevelsLoader {
    internal static var shared = LevelsLoader()
    
    fileprivate var encoder = JSONEncoder()
    fileprivate var decoder = JSONDecoder()
    
    private init () {}
}

extension LevelsLoader {
    
    public func printEncoded(_ model: LevelModel) {
        do {
            let data = try encoder.encode(model)
            
            let string = String(data: data, encoding: .utf8)!
            
            print(string)
        } catch {
            print("failed to print encoded model", error)
        }
    }
    
    public func delete(named: String) -> Bool {
        
        if containsLevel(userGenerated: true, resources: false, named: named), let url = self.levelURL(userGenerated: true, resources: false, named: named) {
            
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print(error)
            }
            
            return true
        }
        
        return false
    }
    
    public func load<T: Decodable>(decodable: T.Type, from url: URL) -> Decodable? {
        do {
            let data = try Data(contentsOf: url)
            
            return try decoder.decode(T.self, from: data)
        } catch {
            print("failed to load", url.deletingPathExtension().lastPathComponent, error)
        }
        
        return nil
    }
    
    public func save<T: Encodable>(encodable: T, as name: String, overwrites: Bool = true) -> Bool {
        do {
            let data = try encoder.encode(encodable)
            
            let documents = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let url = documents.appendingPathComponent(name).appendingPathExtension("json")
            
            if FileManager.default.fileExists(atPath: url.path) && !overwrites {
                return false
            }
            
            try data.write(to: url)
            
            return true
        } catch {
            print("failed to save", name, error)
            return false
        }
    }
    
    public func containsLevel(userGenerated: Bool = true, resources: Bool = true, named: String) -> Bool {
        return levelURLs(userGenerated: userGenerated, resources: resources).contains { (url) -> Bool in
            return url.deletingPathExtension().lastPathComponent == named
        }
    }
    
    public func levelURL(userGenerated: Bool = true, resources: Bool = true, named: String) -> URL? {
        return levelURLs(userGenerated: userGenerated, resources: resources).first(where: { (url) -> Bool in
            return url.deletingPathExtension().lastPathComponent == named
        })
    }
    
    public func levelURLs(userGenerated: Bool = true, resources: Bool = true) -> [URL] {
        
        var urls = [URL]()
        
        if userGenerated, let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let documentURLs = try? FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants).filter({ (url) -> Bool in
            return url.pathExtension == "json"
        }){
            urls.append(contentsOf: documentURLs)
        }
        
        if resources, let resourcesURLs = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) {
            urls.append(contentsOf: resourcesURLs)
        }
        
        return urls
    }
    
    public func loadLevels(userGenerated: Bool = true, resources: Bool = true) -> [LevelModel] {
        var list = [LevelModel]()
        
        self.levelURLs(userGenerated: userGenerated, resources: resources).forEach { (url) in
            guard let model = self.load(decodable: LevelModel.self, from: url) as? LevelModel else {
                return
            }
            
            list.append(model)
        }
        
        return list
    }
}
