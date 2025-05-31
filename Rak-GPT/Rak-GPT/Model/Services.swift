//
//  Services.swift
//  TechAssessment
//
//  Created by Apple on 17/05/25.
//

import Foundation

enum userType: Codable {
    case Bot
    case User
}

struct Chat: Codable {
    var userType: userType
    var message: String
    
    init(userType: userType, message: String) {
        self.userType = userType
        self.message = message
    }
}

struct User: Codable {
    
    var name: String
    var address: String
    var role: String
    
    init(name: String, address: String, role: String) {
        self.name = name
        self.address = address
        self.role = role
    }
    
}

struct Plan {
    
    var title: String
    var descriptor: String
    
    init(title: String, descriptor: String) {
        self.title = title
        self.descriptor = descriptor
    }
    
}
