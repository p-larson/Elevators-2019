//
//  ElevatorsGameSceneDependable.swift
//  ElCore
//
//  Created by Peter Larson on 2/24/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

//public class ElevatorsGameSceneDependent {
//    /// Weak reference to a scene, as a FloorManager must always be retained in one.
//    public unowned let scene: ElevatorsGameScene
//
//    /// Required
//    ///
//    /// - Parameter scene: ElevatorsGameScene
//    public init(_ scene: ElevatorsGameScene) {
//        self.scene = scene
//    }
//}

protocol ElevatorsGameSceneDependent {
    var scene: ElevatorsGameScene { get }
}
