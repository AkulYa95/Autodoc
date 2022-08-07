//
//  SwiftUIView.swift
//  AutoNews
//
//  Created by Ярослав Акулов on 07.08.2022.
//

import SwiftUI

struct TopView: View {
    @State var titleValue = "Title"
    @State var detailLabelValue = "Detail Title"
    @State var alpha = 1
    var body: some View {
        
        HStack(alignment: .center ,spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text(titleValue)
                    .font(.title)
                    .foregroundColor(.white)
                Text(detailLabelValue)
                    .font(.footnote)
                    .foregroundColor(.white)
            }
            Spacer()
            Button(action: {
                UIView.animate(withDuration: 1.5) {
                    self.titleValue = "GG"
                }
            }) {
                Image("like")
                    .resizable()
                    .frame(width: 50, height: 50, alignment: .center)
                    .foregroundColor(.yellow)
            }
        }  .background(Color.purple)
            .padding(16)
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}

import SwiftUI

struct ContentView: View {
    var body: some View {
        List {
            TopView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
