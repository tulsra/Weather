//
//  WeatherDisplayView.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 8/22/24.
//

import SwiftUI

struct WeatherDisplayView: View {
    
    @Environment(RootViewModel.self) var vm: RootViewModel
    
    var body: some View {
        PlaceView(vm: vm)
    }
}

struct PlaceView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Bindable var vm: RootViewModel
    
    var body: some View {
        if $vm.models.count == 0 {
            VStack {
                Text("No data available")
                    .accessibilityIdentifier("no.data.available")
            }
        }
        else {
            GeometryReader { geometry in
                let columns =
                // With GeometryReader
                // (geometry.size.width > geometry.size.height )
                
                // With Size Class
                verticalSizeClass == .compact
                ? [GridItem(.flexible()), GridItem(.flexible())] : [GridItem(.flexible())]
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach($vm.models) { item in
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(item.city.wrappedValue)")
                                            .font(.title)
                                        Spacer()
                                        Text("\(item.analysis.wrappedValue.capitalized)")
                                            .font(.body)
                                    }
                                    Spacer()
                                    VStack {
                                        HStack(spacing: 0) {
                                            ImageDownloaderView(url: item.url.wrappedValue)
                                                .frame(width: 50, height: 50, alignment: .trailing)
                                                .clipped()
                                            Text("\(item.temperature.wrappedValue)")
                                                .font(.subheadline)
                                                .frame(width: 60, height: 30, alignment: .trailing)
                                        }
                                        HStack(spacing: 0) {
                                            Image(systemName: "humidity")
                                            Text("\(item.humidity.wrappedValue)")
                                                .font(.subheadline)
                                                .frame(width: 60, height: 30, alignment: .trailing)
                                        }
                                    }
                                    Divider()
                                }
                                Divider()
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
