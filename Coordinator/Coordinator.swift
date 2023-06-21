//
//  Coordinator.swift
//  HomeGarden
//
//  Created by Anthony Contreras on 6/18/23.
//

import Foundation
import RealityKit
import ARKit

class Coordinator: NSObject, ARSessionDelegate {
    var arView : ARView?
    var mainScene : Experience.PlantScene?
    var anchorsToRemove: [AnchorEntity] = []
    var currentAnchorIndex: Int = 0
    
    let plantViewModel : PlantViewModel
    let memoryViewModel : MemoryViewModel
    init(vm:PlantViewModel, memoryVm:MemoryViewModel){
        self.plantViewModel = vm
        self.memoryViewModel = memoryVm
        do {
            self.mainScene = try Experience.loadPlantScene()
        } catch {
            print("Failed to load main scene: \(error)")
            self.mainScene = nil
        }
        
    }
    
    @objc func onTapped(_ recognizer: UITapGestureRecognizer){
        guard let arView = arView else{
              print("AR view is not available")
              return
          }
        guard let mainScene = mainScene else {
            print("or main scene  is not avialble")
            return
        }

        let location = recognizer.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        let hitTestResults = arView.hitTest(location)
        if let result = results.first{
            
            guard let entity = mainScene.findEntity(named: plantViewModel.selectedPlant) else {
                print("Didn't find model \(plantViewModel.selectedPlant)")
                return
            }
            

            let arAnchor = ARAnchor(name: plantViewModel.selectedPlant, transform: result.worldTransform)
            let anchorEntity = AnchorEntity(anchor: arAnchor)
            entity.position = SIMD3<Float>(0, 0, 0)
            let clonedEntity = entity.clone(recursive: true)
    

            clonedEntity.generateCollisionShapes(recursive: true)
            clonedEntity.scale = SIMD3<Float>(repeating: 0.5)
            clonedEntity.transform = Transform(matrix: result.worldTransform)
            
            anchorEntity.addChild(clonedEntity)
            arView.session.add(anchor: arAnchor)
            arView.scene.addAnchor(anchorEntity)
            self.anchorsToRemove.insert(anchorEntity,at:0)
            
            arView.installGestures(.all, for: clonedEntity)
            
        }else{
            print("result/entity does not equal")
        }
        
    }
 
    func session(_ session:ARSession, didUpdate frame: ARFrame){
        switch frame.worldMappingStatus{
        case .notAvailable:
                memoryViewModel.worldMapStatus = .notAvailable
        case .limited:
            memoryViewModel.worldMapStatus = .limited
        case .extending:
            memoryViewModel.worldMapStatus = .extending
        case .mapped:
            memoryViewModel.worldMapStatus = .mapped
        @unknown default:
            fatalError()
        }
    }
}


extension Coordinator {
    func saveWorldMap(){
        guard let arView = arView else {return}
        arView.session.getCurrentWorldMap { [weak self] worldMap , error in
            if let error = error {
                print("error with saving worldmap \(error)")
                return
            }
            if let worldMap = worldMap {
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(data, forKey: "worldMap")
                    userDefaults.synchronize()
                    self?.memoryViewModel.isSaved = true
                } catch {
                    print("Error archiving world map: \(error)")
                }
            }
        }
    }
    //loading works now, but its onnly one of theo riginal entities, clone them, and they arent movable
    func loadWorldMap() {
        guard let arView = arView else {
            print("AR view is not available")
//            memoryViewModel.error = "R view is not available"
            return
        }
        
        guard let mainScene = mainScene else {
            print("Main scene is not available")
//            memoryViewModel.error = "MAin scene not avialble"
            return
        }
        
        let userDefaults = UserDefaults.standard
        
        guard let data = userDefaults.data(forKey: "worldMap") else {
            print("No data found for 'worldMap' key in UserDefaults")
//            memoryViewModel.error = "no data found for worldmap in userdefaults"
            return
        }
        
        guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else {
            print("Failed to unarchive ARWorldMap from data")
//            memoryViewModel.error = "failed to unarchive worlda from data "
            return
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
        }
        
        for anchor in worldMap.anchors {
            guard let name = anchor.name else {
                print("No name for anchor")
//                memoryViewModel.error = "no name for anchor "
                continue
            }
            
            guard let entity = mainScene.findEntity(named: name) else {
                print("Entity with name '\(name)' not found in the main scene")
//                memoryViewModel.error = "Entity with name '\(name)' not found in the main scene"
                continue
            }
            
            let anchorEntity = AnchorEntity(anchor: anchor)
            let clonedEntityInstance = entity.clone(recursive: true)
            clonedEntityInstance.generateCollisionShapes(recursive: true)
            clonedEntityInstance.scale = SIMD3<Float>(repeating: 0.5)
//            clonedEntityInstance.transform = Transform(matrix: result.worldTransform)
            arView.installGestures(.all, for: clonedEntityInstance)

            anchorEntity.addChild(clonedEntityInstance)
            arView.scene.addAnchor(anchorEntity)

        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.initialWorldMap = worldMap
        configuration.planeDetection = .horizontal
        
        arView.session.run(configuration)
    }

    func resetWorldMap(){
        guard let arView = arView else {return}
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.session.run(configuration,options: [.removeExistingAnchors,.resetTracking])
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "worldMap")
        userDefaults.synchronize()
    }
    func removeEntityButtonPressed() {
        guard let arView = arView  else {return}
        print("remove entity  called")
        guard !anchorsToRemove.isEmpty else {
                return
            }
        let currentAnchorEntity = anchorsToRemove[currentAnchorIndex]

        // Remove the anchor entity from the scene
        arView.scene.removeAnchor(currentAnchorEntity)

        // Increment the current anchor index
        currentAnchorIndex += 1

        // Check if all anchors have been removed
        if currentAnchorIndex >= anchorsToRemove.count {
            // Reset the counter and clear the selection
            currentAnchorIndex = 0
            self.anchorsToRemove.removeAll()
//            self.selectedAnchorEntity = nil
        }
    }
}
