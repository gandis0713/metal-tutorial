/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import OSLog

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {

        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)

        return (r, g, b, o)
    }
}

struct ContentView: View {
    @State var options = Options()
    @State private var baseColor = Color(.sRGBLinear,
                                         red: CGFloat(RenderingOptions.shared.baseColor.x),
                                         green: CGFloat(RenderingOptions.shared.baseColor.y),
                                         blue: CGFloat(RenderingOptions.shared.baseColor.z))
    @StateObject var renderingOptions: RenderingOptions = RenderingOptions.shared

    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                MetalView(options: options)
                    .border(Color.black, width: 2)
            }
            Toggle("Custom Rendering Options", isOn: $renderingOptions.customRenderingOption)

            HStack {
                ColorPicker("Albedo", selection: $baseColor).onChange(of: baseColor) { _ in

                    RenderingOptions.shared.baseColor.x = Float(baseColor.components.red)
                    RenderingOptions.shared.baseColor.y = Float(baseColor.components.green)
                    RenderingOptions.shared.baseColor.z = Float(baseColor.components.blue)

                    os_log(.info, log: OSLog.info, "color: \(RenderingOptions.shared.baseColor)")
                }
            }
            HStack {
                Text("Metallic")
                Slider(value: $renderingOptions.metallic, in: 0.0...1.0, step: 0.01)
                Text(" \(renderingOptions.metallic)")
            }
            HStack {
                Text("Roughness")
                Slider(value: $renderingOptions.roughness, in: 0.0...1.0, step: 0.01)
                Text(" \(renderingOptions.roughness)")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
