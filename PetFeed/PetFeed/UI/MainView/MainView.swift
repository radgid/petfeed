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
    @State private var errorMessage = "" {
        didSet {
            isError = !errorMessage.isEmpty
        }
    }
    @State private var isError = false

    // MARK: - Subviews
    var tabView: some View {
        TabView(selection: $selection) {
            PetsView()
                .tabItem {
                    VStack {
                        Image(systemName: "list.dash")
                        Text("All Posts")
                    }
            }.tag(0)
            FavouritePetsView()
                .onAppear {
                    self.fetchFavourite()
            }.tabItem {
                VStack {
                    Image(systemName: "heart.fill")
                    Text("Favourites")
                }
            }.tag(1)
        }.onReceive(self.store.$state, perform: { state in
            if let failure = state.failure {
                self.errorMessage = failure.localizedDescription
            } else {
                self.errorMessage = ""
            }
        })
        .overlay(ZStack {
            if self.isError {
                ErrorView(errorMessage: $errorMessage.wrappedValue,
                          isError: $isError)
                    .transition(.asymmetric(insertion: .move(edge: .top),
                                            removal: .move(edge: .top)))
                    .animation(.easeInOut(duration: 0.2))
                    .zIndex(0)
            } else {
                EmptyView()
            }
        }, alignment: .top)
    }

    // MARK: - Body
    var body: some View {
        tabView.onAppear {
            self.fetch()
            UITableView.appearance().separatorStyle = .none
        }
    }

    // MARK: - Actions
    private func fetch() {
        store.send(.fetch(page:1))
    }
    private func fetchFavourite() {
        store.send(.fetchFavourite(page:1))
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(Settings.storeMock)
    }
}
