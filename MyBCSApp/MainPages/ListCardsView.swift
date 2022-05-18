//
//  ListCardsView.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/12/22.
//

import SwiftUI

struct ListCardsView: View {
    var body: some View {
        NavigationView {
            VStack {
                cardsView
            }
            .overlay(newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    private var newMessageButton: some View {
            Button {

            } label: {
                HStack {
                    Spacer()
                    Text("+ New Message")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical)
                    .background(Color.blue)
                    .cornerRadius(32)
                    .padding(.horizontal)
                    .shadow(radius: 15)
            }
    }
    
    private var cardsView: some View {
        ScrollView {
            HStack{
                
            }
        }
    }
}

struct ListCardsView_Previews: PreviewProvider {
    static var previews: some View {
        ListCardsView()
    }
}
