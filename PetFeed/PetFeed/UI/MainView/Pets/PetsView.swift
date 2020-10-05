//
//  PetsView.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import SwiftUI
import Combine


struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = [CGFloat]
    
    static var defaultValue: [CGFloat] = [0]
    
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

struct PetsView: View {
    
    @Environment(\.imageCache) var cache: ImageCache
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var petStore: PetStore
    @EnvironmentObject var managePetStore: ManagePetStore
    private var pets: [Pet] {
        petStore.state.fetchResult
    }
    
    @State private var offsetY: CGFloat = 0.0
    
    private var petsView: some View {
        let isPresented = Binding(get: {return (self.managePetStore.state.selectedPet != nil)}, set: {_,_ in })
        return
            ZStack(alignment: .top){
                PullToRefresh(triggerOffset: $offsetY, {self.fetch()})
                GeometryReader { _ in
                    ScrollView(.vertical) {
                        VStack {
                            GeometryReader { insideGeo in
                                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: [insideGeo.frame(in: .global).minY])
                            }
                            ForEach(self.pets, id: \.id) {pet in
                                PetRow(petId: pet.id)
                                    .padding(.horizontal)
                                    .padding(.bottom, 5)
                                    .onTapGesture {
                                        self.managePetStore.send(.select(pet: pet))
                                    }.sheet(isPresented: isPresented, onDismiss: {
                                        self.managePetStore.send(.clear)
                                        Notification.send(name: .didDismissPetDetail)
                                    }) {
                                        PetImageView().environmentObject(self.petStore)
                                            .environmentObject(self.managePetStore)
                                    }
                            }
                        }
                    }.zIndex(0)
                }.onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.offsetY = value[0]
                }
            }
    }
    
    var body: some View {
        VStack {
            if pets.isEmpty {
                NoDataFoundView()
            } else {
                petsView
            }
        }.onAppear{
            fetchIfErroredPreviously()
        }
    }
    
    // MARK: - Actions
    private func fetch() {
        petStore.send(.fetch(page:1))
    }
    
    private func fetchIfErroredPreviously() {
        if self.petStore.state.failure != nil {
            self.fetch()
        }
    }
}

struct PetsView_Previews: PreviewProvider {
    static var previews: some View {
        PetsView()
            .environmentObject(PreviewSupport.petStoreMock)
            .environmentObject(PreviewSupport.managePetStoreMock)
            .environment(\.imageCache, PetApiMock().cache)
            .onAppear {
                PreviewSupport.petStoreMock.send(.fetch(page: 1))
        }
    }
}
