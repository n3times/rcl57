//
//  rcl57App.swift
//  rcl57
//
//  Created by Paul Novaes on 2/6/22.
//

import SwiftUI

@main
struct rcl57App: App {
    var body: some Scene {
        WindowGroup {
            CalcView(pentaSeven: Penta7())
        }
    }
}
