//
//  ProfileManager.swift
//  SPARC
//
//  Created by Anshika Thakur on 25/02/26.
//

import Foundation
import SwiftUI

@MainActor
class ProfileManager: ObservableObject {
    static let shared = ProfileManager()
    
    @Published var profile = AthleteProfile()
    
    private let key = "sparc_profile"
    
    init() {
        load()
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(AthleteProfile.self, from: data) {
            profile = decoded
        }
    }
}
