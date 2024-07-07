//
//  City.swift
//  Cities
//
//  Created by Vishnu Tejaa on 3/19/24.
//

import Foundation
struct City: Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var imageName: String = "default"
    var latitude: Double
    var longitude: Double
}
