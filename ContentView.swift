//
//  ContentView.swift
//  HomeGarden
//
//  Created by Anthony Contreras on 6/17/23.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @StateObject private var plantVM : PlantViewModel = PlantViewModel()
    @StateObject private var memoryVM : MemoryViewModel = MemoryViewModel()
    @State private var confirmCancel : Bool = false
    @Binding var loading : Bool
    
    let plants :[String] = ["succulentPlantPot","cactusPlantPot","arrayPlants","fancyPot","fernPot","plantRockPot"]
    
    var body: some View {
        VStack{
            HStack{

                Text(memoryVM.worldMapStatus.rawValue).font(.largeTitle)
//                Text(memoryVM.error).font(.title)
//                Text(name)
       
                
            }.frame(maxWidth:.infinity,maxHeight:60).background(.blue)
            ARViewContainer(plantViewModel: plantVM, memoryViewModel: memoryVM).edgesIgnoringSafeArea(.all)
        
                VStack{
                    HStack{
                        Button("Save"){
                            memoryVM.onSave()
                        }.buttonStyle(.borderedProminent)
                        Button("Clear"){
                            self.confirmCancel = true
                        }.buttonStyle(.bordered)
              
                        Button {
                            memoryVM.onUndo()
                        } label: {
                            Image(systemName:"arrow.uturn.left")
                                .padding()
                                .background(Circle().fill(.gray).opacity(0.6))
                        }

                    }
                    ScrollView(.horizontal){
                    HStack{
                        ForEach(plants,id:\.self){
                            plant in
                            Image(plant)
                                .resizable()
                                .frame(width: 100,height:100)
                                .border(.red, width: plantVM.selectedPlant == plant ? 1.0 : 0.0)
                                .onTapGesture {
                                    plantVM.selectedPlant = plant
                                }
                        }
                    }
                }
                .alert("ARWorld has been saved", isPresented: $memoryVM.isSaved) {
                    Button(role: .cancel, action: {}) {
                        Text("Ok")
                    }
                }
                .alert("Are you sure you want to clear?", isPresented: $confirmCancel) {
                    Button(role: .destructive, action: {
                        memoryVM.onReset()
                    }) {
                        Text("Yes")
                    }
                    Button(role: .cancel, action: {}) {
                        Text("No")
                    }
                }
            }
        }
        .onAppear{
            self.loading = false
        }
    }
    
}

struct ARViewContainer: UIViewRepresentable {
    let plantViewModel : PlantViewModel
    let memoryViewModel : MemoryViewModel

    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.onTapped)))

        
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        config.environmentTexturing = .automatic

        session.run(config)
        context.coordinator.arView = arView
        arView.session.delegate = context.coordinator

        arView.addCoachingOverlay()
        arView.environment.sceneUnderstanding.options.insert(.occlusion)
        
        memoryViewModel.onSave = {
            context.coordinator.saveWorldMap()
        }
        memoryViewModel.onReset = {
            context.coordinator.resetWorldMap()

        }
        memoryViewModel.onUndo = {
            context.coordinator.removeEntityButtonPressed()
        }
        context.coordinator.loadWorldMap()
 
        return arView
        
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator(vm: plantViewModel, memoryVm: memoryViewModel)
    }
    func updateUIView(_ uiView: ARView,  context: Context) {}
    
}

//#if DEBUG
//struct ContentView_Previews : PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//#endif
