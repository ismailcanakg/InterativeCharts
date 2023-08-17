//
//  ContentView.swift
//  InterativeCharts
//
//  Created by İsmail Can Akgün on 17.08.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("Interactive Char's")
        }
    }
}

#Preview {
    ContentView()
}
