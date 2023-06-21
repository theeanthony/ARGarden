//
//  Entity+Extensions.swift
//  HomeGarden
//
//  Created by Anthony Contreras on 6/20/23.
//

import Foundation
import RealityKit

extension Entity: HasCollision {
    var collision: CollisionComponent? {
        get {
            return components[CollisionComponent.self] as? CollisionComponent
        }
        set {
            if let newValue = newValue {
                // Remove any existing collision components
                components.remove(CollisionComponent.self)
                // Add the new collision component
                components.set(newValue)
            } else {
                // Remove the collision component
                components.remove(CollisionComponent.self)
            }
        }
    }
}
