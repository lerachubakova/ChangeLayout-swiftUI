//
//  ContentView.swift
//  ChangeLayout
//
//  Created by Valeriya Chubakova on 22.09.23.
//

import SwiftUI

enum LayoutType {
    case list
    case grid

    var title: String {
        switch self {
        case .list: return "List"
        case .grid: return "Grid"
        }
    }

    mutating func toggle() {
        switch self {
        case .list: self = .grid
        case .grid: self = .list
        }
    }
}

struct ContentView: View {
    @State var type: LayoutType = .list

    @State var selectedID: Int = 0

    var body: some View {
        TabView {
            table
                .tabItem {
                    Label("Feed", systemImage: "square.stack.3d.down.right")
                }
        }
    }

    var table: some View {
        VStack {
            //            GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    switch type {
                    case .list:
                        getContent()
                    case .grid:
                        getGridContent()
                    }
                }
                .if(type == .list) {
                    $0.scrollTargetBehavior(.paging)
                        .ignoresSafeArea()
                }
                .scrollIndicators(.hidden)
                .onChange(of: type) {
                    debugPrint("MYLOG: \(Self.self): SCROLL TO \(selectedID) ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
                    switch type {
                    case .list:
                        proxy.scrollTo(privateIndex, anchor: .top)
                    case .grid:
                        proxy.scrollTo(selectedID, anchor: .top)
                    }
                }
            }

        }


        .onChange(of: selectedID){ oldValue, newValue in
//            debugPrint("MYLOG: \(Self.self): NEW SELECTED ID ------- \(newValue) ")
        }
        .overlay {
            Button(type.title) {
                if type == .list {
                    type = .grid
                } else {
                    type = .list
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding()
        }
    }

    @ViewBuilder
    func getGridContent() -> some View {
        VStack(spacing: 3) {
            LazyVGrid(columns: [.init(spacing: 3), .init()], spacing: 0) {
                ForEach(models[0...1].indices, id: \.self) { ind in
                    getCell(ind)
                }
            }
            LazyVGrid(columns: [ .init(spacing: 3),  .init(spacing: 3), .init()], spacing: 3) {
                ForEach(models[2...].indices, id: \.self) { ind in
                    getCell(ind)
                }
            }
        }
        .padding(.horizontal, 4)
    }

    func getCell(_ index: Int) -> some View {
        getImage(ind: index)
            .resizable()
            .aspectRatio(120/214, contentMode: .fit)
            .overlay {
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        HStack(spacing: 0) {
                            getImage(ind: index)
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 24, height: 24, alignment: .center)
                                .background (.gray)
                                .overlay { Circle().stroke(.white, lineWidth: 1)}
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 0) {
                                Text("\(models[index]) \(models[index])")
                                    .font(.system(size: 10, weight: .medium))
                                Text("\(models[index]) \(models[index])")
                                    .font(.system(size: 8, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 1)
                            .padding(.leading, 16)

                            Spacer()
                        }
                        .padding(10)
                    }
                    .onChange(of: geo.frame(in: .global)) { oldValue, newValue in
//                         debugPrint("MYLOG: \(Self.self): old new")
                        checkGeo(index: index, oldValue: oldValue, newValue: newValue)
//                        Task {
//                            await MainActor.run {
//                                checkGeo(index: index, oldValue: oldValue, newValue: newValue)
//                            }
//                        }
                    }

                }
            }
            .onAppear {
//                debugPrint("MYLOG: \(Self.self): APPEAR IN GRID index \(index)")
            }
            .cornerRadius(2)
            .id(index)
    }

    @State var privateIndex: Int = -1 {
        willSet {
             debugPrint("MYLOG: \(Self.self): PRIVATE INDEX \(newValue)")
        }
    }

    func checkGeo(index: Int, oldValue: CGRect, newValue: CGRect) {
//        switch type {
//        case .list:
//            if oldValue.minY > 0 && newValue.minY <= 0 {
//                selectedID = index
//            } else if oldValue.minY < 0 && newValue.minY >= 0 {
//                selectedID = index
//            }
//        case .grid:
            if oldValue.minY > 0 && newValue.minY <= 0 {
//                debugPrint("MYLOG: \(Self.self): models \(index) IS GONE!!!")
                privateIndex = index
            } else if oldValue.minY < 0 && newValue.minY >= 0 {
//                debugPrint("MYLOG: \(Self.self): models \(index) IS HERE!!!!")
                privateIndex = index
            }
//        }
    }

    func getContent() -> some View {
        LazyVStack(spacing: 0) {
            ForEach(models.indices, id: \.self) { ind in
                getCell(index: ind, type: type)
                    .containerRelativeFrame(.horizontal)
                    .containerRelativeFrame(.vertical)
            }
        }
    }

    func getCell(index: Int, type: LayoutType) -> some View {
        getImage(ind: index)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
            .overlay {
                //                GeometryReader { geo in
                VStack {
                    Spacer()
                    Text("\(models[index])".prefix(4))
                        .fontWeight(.light)
                        .font(.system(size: 32))
                        .padding(24)
                        .background(.black.opacity(0.6))
                        .clipShape(Circle())
                    Spacer()
                }

            }
            .onAppear(){
                selectedID = index
            }
            .id(index)
    }


    var models: [String] {
        (0...1200).map {
            "№\(($0))"
        }
    }

    let immmages: [Image] = [
        .init(.postImage1),
        .init(.postImage2),
        .init(.postImage3),
        .init(.product1),
        .init(.product2),
        .init(.product3)
    ]

    var images: [Image] {
        immmages + immmages + immmages
    }

    func getImage(ind: Int) -> Image {
        images[Int(Double(ind).truncatingRemainder(dividingBy: 10))]
    }

}

#Preview {
    ContentView()
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
