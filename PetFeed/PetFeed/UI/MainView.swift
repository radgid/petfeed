//
//  ContentView.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @State private var selection = 0

    
    /// Tabs definition
    var tabView: some View {
        TabView(selection: $selection){
            Text("All Posts")
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "list.dash")
                        Text("All Posts")
                    }
                }
                .tag(0)
            Text("Favourites")
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "heart")
                        Text("Favourites")
                    }
                }
                .tag(1)
        }
    }
    
    //MARK: - Main View
    /// Main View definition
    var body: some View {
        tabView
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
