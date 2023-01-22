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
            Text("Hello, Metal!")
            MetalView()
                .border(Color.black, width: 0)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
