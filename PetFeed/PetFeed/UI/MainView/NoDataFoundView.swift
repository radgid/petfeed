//
//  NoDataFoundView.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 08/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct NoDataFoundView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "nosign").font(.largeTitle)
                .padding()
              Text("No Pets available")
                  .font(.body)
                .foregroundColor(Color(.systemGray))
            Spacer()
          }.opacity(0.6)
    }
}

struct NoDataFoundView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataFoundView()
    }
}
