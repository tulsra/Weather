//
//  RootView.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 10/9/24.
//

import SwiftUI

struct RootView: View {
    
    @State private(set) var vm: RootViewModel
    
    var body: some View {
        NavigationStack {
            if vm.isLoading {
                VStack {
                    // Using UIKit element just for example
                    // Can be replaced with ProgressView SwiftUI
                    ActivityIndicator(style: .large)
                        .accessibilityIdentifier("activity.indicator.view")
                    Text("Request in progress")
                }
                
            } else {
                WeatherDisplayView()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .searchable(text: $vm.searchText)
        .onAppear {
            vm.getWeatherData()
            vm.getLocationDetails()
        }
        .environment(vm)
    }
}
