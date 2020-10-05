//
//  PullToRefresh.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/10/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI
import Combine

struct PullToRefresh: View {
    init(triggerOffset: Binding<CGFloat>, _ completion: @escaping (() -> Void) ) {
        self.completion = completion
        self._triggerOffset = triggerOffset
    }
    
    private let completion: (() -> Void)
    private var pullToRefreshPublisher : PassthroughSubject<Bool, Never> {
        let publisher = PassthroughSubject<Bool, Never>()
        cancellable = publisher.debounce(for: .seconds(0.3),
                                        scheduler: RunLoop.current)
            .removeDuplicates()
            .sink { _ in
                completion()
            }
        return publisher
    }
    
    @State private var cancellable: AnyCancellable?
    @Binding private var triggerOffset: CGFloat
    
    private var isShowPullToRefresh: Bool {
        let shouldShow = triggerOffset > Constants.pullToRefreshOffset
        if shouldShow {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                pullToRefreshPublisher.send(true)
            }
        }
        return shouldShow
    }
    
    var body: some View {
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
}

struct PullToRefresh_Previews: PreviewProvider {
    static var previews: some View {
        PullToRefresh(triggerOffset: .constant(0), {})
    }
}
