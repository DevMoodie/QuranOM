//
//  Verse.swift
//  QuranOM
//
//  Created by Moody on 2024-09-22.
//

import Foundation

struct Verse: Codable {
    let text: String
    let surah: Surah
    let audio: String
}
