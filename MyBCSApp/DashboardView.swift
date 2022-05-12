//
//  DashboardView.swift
//  MyBCSApp
//
//  Created by Ana Savu on 5/12/22.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()
            Text("This is the Dashboard View")
                .font(.largeTitle)
            
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
