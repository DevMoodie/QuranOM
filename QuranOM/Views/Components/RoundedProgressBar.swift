//
//  CircularProgressBar.swift
//  QuranOM
//
//  Created by Moody on 2024-09-22.
//

import SwiftUI

struct RoundedProgressBar: View {
    var progress: Double // Progress from 0 to 1

    var body: some View {
        ZStack {
            // Background circle
            RoundedRectangle(cornerRadius: 25.0)
                .stroke(lineWidth: 10.0)
                .opacity(0.3)
                .foregroundColor(.gray)

            // Foreground progress circle
            RoundedRectangle(cornerRadius: 25.0)
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(.black)
                .rotationEffect(Angle(degrees: 270.0)) // Start from top
                .animation(.linear, value: progress) // Animate progress change
        }
    }
}
