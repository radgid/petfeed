//
//  ErrorView.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 07/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    
    @Environment(\.presentationMode) var presentationMode
    var errorMessage: String
    @Binding var isError: Bool
    var isInNavigationLink: Bool = false
    
    var body: some View {
            ZStack(alignment: .top) {
                HStack(alignment: .top, spacing: 30) {
                    VStack(alignment: .center) {
                        Text(self.errorMessage)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .foregroundColor(Color(.label))
                            .font(.system(.callout))
                            .truncationMode(.middle)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.isError.toggle()
                            }
                        }
                    .modifier(ErrorViewModifier())
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.isError.toggle()
                        }
                    .padding(.horizontal, 20)
                }
            }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(errorMessage: "Test error message here", isError: .constant(false))
    }
}
