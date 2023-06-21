//
//  WelcomePageView.swift
//  HomeGarden
//
//  Created by Anthony Contreras on 6/21/23.
//

import SwiftUI

struct WelcomePageView: View {
    
    @State private var continueToAR : Bool = false
    @State private var loading : Bool = false

    var body: some View {
        VStack{
            Spacer()
            Image(uiImage: UIImage(named:"garden")!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:100)
            Text("Living Room Garden AR").font(.largeTitle).foregroundColor(.white)
            Spacer()
            


            if loading {
                ProgressView()
            }else{
                Button {
                    self.continueToAR = true
                    self.loading = true
                } label: {
                    HStack{
                        Spacer()
                        Text("Start")
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .padding(.vertical,10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.gray))
                        Spacer()
                    }
                }
            }
            Spacer()

        }
        .background(.black)
        .fullScreenCover(isPresented: $continueToAR) {
            ContentView(loading: $loading)
        }
    }
}

struct WelcomePageView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePageView()
    }
}
