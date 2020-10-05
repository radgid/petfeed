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
    @EnvironmentObject var store: PetStore
    @EnvironmentObject var favouriteStore: FavouritePetStore
    @State private var selection = 0
    @Environment(\.imageCache) var cache: ImageCache

    private var errorView: some View {
        let isError = Binding(get: {return self.store.state.failure != nil}, set: {_,_ in })
        return ZStack {
            if isError.wrappedValue {
                 ErrorView(errorMessage: self.store.state.failure.unsafelyUnwrapped.localizedDescription,
                                 isError: isError)
                    .transition(.asymmetric(insertion: .move(edge: .top),
                                            removal: .move(edge: .top)))
                    .animation(.easeInOut(duration: 0.2))
                    .zIndex(0)
            } else {
                 EmptyView()
            }
        }
    }
    
    private var petsView: some View {
        PetsView()
            .tabItem {
                VStack {
                    Image(systemName: "list.dash")
                    Text("All Posts")
                }
        }.tag(0)
    }
    
    private var favouritePetsView: some View {
        FavouritePetsView()
            .tabItem {
                VStack {
                    Image(systemName: "heart.fill")
                    Text("Favourites")
                }
        }.tag(1)
    }
    
    // MARK: - Subviews
    var tabView: some View {
        TabView(selection: $selection) {
            petsView
            favouritePetsView
        }.onAppear{
            fetch()
        }.overlay(errorView, alignment: .top)
    }

    // MARK: - Body
    var body: some View {
        tabView
    }

    // MARK: - Actions
    private func fetch() {
        store.send(.fetch(page:1))
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(PreviewSupport.petStoreMock)
            .environmentObject(PreviewSupport.favouritePetStoreMock)
    }
}
