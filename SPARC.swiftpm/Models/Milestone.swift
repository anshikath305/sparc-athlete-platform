//
//  Milestone.swift
//  SPARC
//
//  Created by Anshika Thakur on 25/02/26.
//
import Foundation

struct Milestone: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let date: Date
}
