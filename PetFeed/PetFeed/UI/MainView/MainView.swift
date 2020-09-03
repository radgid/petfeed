//
//  ContentView.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI
import Combine


/// Row with Pet for display
struct PetRow: View {
    let pet: Pet
    @Environment(\.imageCache) var cache: ImageCache
    @EnvironmentObject var store: AppStore
    
    init(pet: Pet) {
        self.pet = pet
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            AsyncImage(url: URL(string: pet.url),
                       placeholder: Image(systemName: "hourglass").font(.title),
                       cache: self.cache,
                       service: store.environment.service)
                .frame(height: 180)
                .padding()
                .shadow(color: Color.white.opacity(0.9), radius: 10, x: -10, y: -10)
                .shadow(color: Color.gray.opacity(0.5), radius: 14, x: 14, y: 14)
            Spacer()
        }.overlay(Button(action: {
            Log.user().info(message: "pressed Favourite")
        }, label: { Image(systemName: "heart")
            .font(.body)
            .padding()}).buttonStyle(BorderlessButtonStyle())
            ,alignment: .bottomTrailing)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}

/// Main View
struct MainView: View {
    @EnvironmentObject var store: AppStore
    @State private var selection = 0
    @Environment(\.imageCache) var cache: ImageCache
    
    /// Tabs definition
    var tabView: some View {
        TabView(selection: $selection) {
            PetsView(pets: store.state.fetchResult)
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
    
    // MARK: - Body -
    /// Main View definition
    var body: some View {
        tabView.onAppear {
            self.fetch()
            UITableView.appearance().separatorStyle = .none
        }
    }
    
    //MARK: Actions
    private func fetch() {
        store.send(.fetch(page:1))
    }
}

/// Pets Subview
struct PetsView: View {
    let pets: [Pet]
    
    var body: some View {
        VStack{
            List {
                ForEach(pets) { pet in
                    PetRow(pet: pet).onTapGesture {
                        Log.user().info(message: "pressed Dog detail")
                    }
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(Settings.storeMock)
    }
}
