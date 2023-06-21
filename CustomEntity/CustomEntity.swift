//
//  CustomEntity.swift
//  HomeGarden
//
//  Created by Anthony Contreras on 6/20/23.
//

import Foundation
import RealityKit
import Combine

class CustomEntity: Entity {
    var modelName: String?
    var modelComponent: ModelComponent?
    var cancelable : AnyCancellable?
    init(modelName: String) {
        super.init()
        self.modelName = modelName
        loadModel()
    }
    
    required init() {
        super.init()
    }
    
    private func loadModel() {
        guard let modelName = modelName else {
            print("Model name is missing")
            return
        }
        
        // Load the model asynchronously
//        ModelEntity.loadModelAsync(named: modelName)
//            .sink { loadCompletion in
//                if case let .failure(error) = loadCompletion{
//                    print("unable to load entity \(error)")
//                }
//                self.cancellable?.cancel()
//            } receiveValue: { <#ModelEntity#> in
//                <#code#>
//            }

    }
}
