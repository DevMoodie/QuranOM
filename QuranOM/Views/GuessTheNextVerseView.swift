//
//  GuessTheNextVerseView.swift
//  QuranOM
//
//  Created by Moody on 2024-09-23.
//

import SwiftUI

struct GuessTheNextVerseView: View {
    @StateObject private var gTNVVM: GuessTheNextVerseViewModel = GuessTheNextVerseViewModel()
    @EnvironmentObject var adAndCoinManager: AdAndCoinManager
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    GuessTheNextVerseView()
}
