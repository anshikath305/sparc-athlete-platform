//
//  MilestoneManager.swift
//  SPARC
//
//  Created by Anshika Thakur on 25/02/26.
//
import Foundation

@MainActor
final class MilestoneManager: ObservableObject {
    static let shared = MilestoneManager()
    
    @Published var milestones: [Milestone] = []
    private let key = "sparc_milestones"
    
    init() {
        load()
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(milestones) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Milestone].self, from: data) {
            milestones = decoded
        }
    }
    
    func addMilestone(title: String, description: String, date: Date) {
        let newMilestone = Milestone(
            title: title,
            description: description,
            date: date
        )
        milestones.insert(newMilestone, at: 0)
        save()
    }
}
