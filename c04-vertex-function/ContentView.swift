//
//  ContentView.swift
//  c04-vertex-function
//
//  Created by user on 2023/01/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("04 Vertex Function")
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
