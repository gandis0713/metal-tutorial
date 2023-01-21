//
//  ContentView.swift
//  01-hello-world
//
//  Created by user on 2023/01/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
          MetalView()
            .border(Color.black, width: 2)
          Text("Hello, Metal!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
