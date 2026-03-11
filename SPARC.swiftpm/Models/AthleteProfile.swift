//
//  AthleteProfile.swift
//  SPARC
//
//  Created by Anshika Thakur on 25/02/26.
//
import Foundation
import SwiftUI

struct AthleteProfile: Codable {
    var name: String = ""
    var sport: String = ""
    var level: String = ""
    var location: String = ""
    var bio: String = ""
    var achievements: [Achievement] = []
}

struct Achievement: Identifiable, Codable {
    var id = UUID()
    var title: String
    var year: String
    var imageData: Data? = nil
}
