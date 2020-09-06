//
//  PetImageView.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 04/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import SwiftUI

struct PetImageView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var store: AppStore
    let petImage: Image
    let pet: Pet

    private var favColor: Color {
        return pet.isFavourite ? .accentColor : .gray
    }

    var body: some View {
        NavigationView {
            VStack {
                petImage
                    .resizable()
                    //                .padding()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                self.presentationMode.wrappedValue.dismiss()
            }
            .overlay(Button(action: {
                Log.user().info(message: "pressed Favourite")
            }, label: { Image(systemName: "heart.fill")
                .font(.body)
                .foregroundColor(favColor)
                .padding()}).buttonStyle(BorderlessButtonStyle()),
                     alignment: .bottomTrailing)
        }
    }
}

struct PetImageView_Previews: PreviewProvider {
    static var previews: some View {
        PetImageView(petImage: PetApiMock().petImage(),
                     pet: Pet("dog1.jpg", isFavourite: false))
            .environmentObject(Settings.storeMock)
    }
}
