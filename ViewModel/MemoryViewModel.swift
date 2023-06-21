//
//  MemoryViewModel.swift
//  HomeGarden
//
//  Created by Anthony Contreras on 6/18/23.
//

import Foundation


class MemoryViewModel : ObservableObject {
    var onSave : () -> Void = {}
    var onReset : () -> Void = {}
    var onUndo : () -> Void = {}
    @Published var isSaved : Bool = false
    @Published var worldMapStatus : WorldMapStatus = .notAvailable
    @Published var loadedNames : [String] = []
    @Published var isLoading : Bool = false
//    @Published var error : String = ""

}

