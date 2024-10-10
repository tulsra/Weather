//
//  WeathermanApp.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 10/9/24.
//

import SwiftUI

@main
struct WeathermanApp: App {
    var body: some Scene {
        WindowGroup {
            #if TEST
                MockWeathermanFactory.shared.rootCoordinator().rootView()
            #else
                WeathermanFactory.shared.rootCoordinator().rootView()
            #endif
        }
    }
}
