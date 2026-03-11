//
//  VoiceReflection.swift
//  SPARC
//
//  Created by Anshika Thakur on 25/02/26.
//

import Foundation

struct VoiceReflection: Identifiable, Codable {
    var id = UUID()
    let fileName: String
    let date: Date
    
    var url: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths.first ?? FileManager.default.temporaryDirectory
        return documentDirectory.appendingPathComponent(fileName)
    }
}
