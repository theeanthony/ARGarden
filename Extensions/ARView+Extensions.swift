//
//  ARView+Extensions.swift
//  HomeGarden
//
//  Created by Anthony Contreras on 6/18/23.
//

import Foundation
import RealityKit
import ARKit

extension ARView{
    func addCoachingOverlay(){
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.session = self.session
        self.addSubview(coachingOverlay)
    }
}
