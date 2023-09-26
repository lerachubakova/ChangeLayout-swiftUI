//
//  ContentView.swift
//  DynamicGridZoom
//
//  Created by Alex Marchant on 06/06/2023.
//

import SwiftUI

struct ContentView2: View {
    let data = (1...300).map { "\($0)" }

    @State private var size: CGFloat = 100

    @State private var gridWidth: CGFloat = 0

    var body: some View {

        let columns = [
            GridItem(.adaptive(minimum: size), spacing: 2)
        ]

        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(data, id: \.self) { item in
                    GridCell(item: item, size: size)
                }
            }
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            self.gridWidth = proxy.frame(in: .local).width
                        }
                }
            )
        }
        .overlay {
            Button("Action") {
                withAnimation {
                    if self.size == gridWidth {
                       size = 100
                    } else {
                        self.size = gridWidth
                    }
                }
            }
            .foregroundStyle(.red)
            .padding()
            .background(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()

        }
        .padding(.horizontal, 2)
    }

}

struct GridCell: View {

    let item: String
    let size: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .frame(height: size)
                .foregroundColor(.blue)
            Text("\(item)")
                .foregroundColor(.white)
        }
    }
}
#Preview {
    ContentView2()
}

import SwiftUI

struct GridZoomStages
{
    static var zoomStages: [Int]
    {
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            if UIDevice.current.orientation.isLandscape
            {
                return [4, 6, 10, 14, 18]
            }
            else
            {
                return [4, 6, 8, 10, 12]
            }
        }
        else
        {
            if UIDevice.current.orientation.isLandscape
            {
                return [4, 6, 8, 9]
            }
            else
            {
                return [1, 2, 4, 6, 8]
            }
        }
    }

    static func getZoomStage(at index: Int) -> Int
    {
        if index >= zoomStages.count
        {
            return zoomStages.last!
        }
        else if index < 0
        {
            return zoomStages.first!
        }
        else
        {
            return zoomStages[index]
        }
    }
}

