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
    @EnvironmentObject var store: AppStore
    @State private var pets: [Pet] = []
    @State private var isPresented: Bool = false
    @State private var selection: Pet?
    private var fetchRequest = PassthroughSubject<CGFloat, Never>()
    @State private var cancellable: AnyCancellable?
    @State private var offsetY: CGFloat = 0.0 {
        didSet {
            if offsetY > Constants.pullToRefreshOffset {
                isShowPullToRefresh = true
                cancellable = fetchRequest.debounce(for: .seconds(1),
                                scheduler: RunLoop.current)
                    .removeDuplicates()
                    .sink { _ in
                        self.fetch()
                }
                fetchRequest.send(offsetY)
            } else {
                isShowPullToRefresh = false
            }
        }
    }
    
    private var pullToRefreshView: some View {
        VStack {
            Spacer().frame(height: 20)
            Image(systemName: "arrowtriangle.up")
                .foregroundColor(Color(.systemBlue))
                .rotationEffect(.degrees(self.isShowPullToRefresh ? 180 : 0))
                .animation(Animation.easeInOut(duration:0.5))
            Text("Refresh Pets ...")
                .font(.caption)
                .foregroundColor(Color(.systemBlue))
        }.opacity(self.isShowPullToRefresh ? 1 : 0)
        .animation(Animation.easeIn(duration:0.3))
    }
    
    @State private var isShowPullToRefresh: Bool = false
    
    var body: some View {
        VStack {
            if pets.isEmpty {
                NoDataFoundView()
            } else {
                ZStack(alignment: .top){
                    self.pullToRefreshView
                    GeometryReader { outsideGeo in
                        ScrollView(.vertical) {
                            VStack {
                                GeometryReader { insideGeo in
                                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: [insideGeo.frame(in: .global).minY])
                                }
                                ForEach(self.pets, id: \.id) {pet in
                                    PetRow(pet: pet)
                                        .padding(.horizontal)
                                        .padding(.bottom, 5)
                                        .onTapGesture {
                                            self.selection = pet
                                            self.isPresented.toggle()}
                                        .sheet(isPresented: self.$isPresented) {
                                            //TODO: show the backdrop to soften the popup appearance
                                            if self.selection != nil {
                                                //TODO: change the dependency injection to the store action in order to eliminate UI glitches when reloading the RowView
                                                PetImageView(petImage: self.selection!.image(from: self.cache), pet: self.selection!)
                                                    .environmentObject(self.store)
                                            } else {
                                                EmptyView()
                                            }
                                    }
                                }
                            }
                        }.zIndex(0)
                    }.onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        self.offsetY = value[0]
                    }
                }
            }
        }.onReceive(self.store.state.$fetchResult) { fetchResult in
            self.pets = fetchResult
        }
    }
    
    // MARK: - Actions
    private func fetch() {
        store.send(.fetch(page:1))
    }
}
