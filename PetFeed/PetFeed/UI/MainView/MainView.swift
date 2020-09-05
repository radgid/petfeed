//
//  ContentView.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI
import Combine


/// Main View
struct MainView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var selection = 0
    @Environment(\.imageCache) var cache: ImageCache
    
    //MARK: - Subviews
    var tabView: some View {
        TabView(selection: $selection) {
            PetsView(pets: store.state.fetchResult)
                .tabItem {
                    VStack {
                        Image(systemName: "list.dash")
                        Text("All Posts")
                    }
            }.tag(0)
            FavouritePetsView(pets: store.state.fetchFavouriteResult)
                .onAppear {
                    self.fetchFavourite()
            }.tabItem {
                VStack {
                    Image(systemName: "heart.fill")
                    Text("Favourites")
                }
            }.tag(1)
        }
    }
    
    // MARK: - Body
    var body: some View {
        tabView.onAppear {
            self.fetch()
            UITableView.appearance().separatorStyle = .none
        }
    }
    
    //MARK: - Actions
    private func fetch() {
        store.send(.fetch(page:1))
    }
    private func fetchFavourite() {
        store.send(.fetchFavourite(page:1))
    }
}

//MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(Settings.storeMock)
    }
}
