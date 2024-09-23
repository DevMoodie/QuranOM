//
//  QuranAPIResponse.swift
//  QuranOM
//
//  Created by Moody on 2024-09-22.
//

import Foundation

struct QuranAPIResponse: Codable {
    let data: Verse
}

struct EnglishQuranAPIResponse: Codable {
    let data: Ayah
}
