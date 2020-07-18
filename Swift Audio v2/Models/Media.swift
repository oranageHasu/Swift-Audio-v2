//
//  Media.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-11.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import Foundation

class Media: Identifiable {
    // id of the Media within the User's library
    var id: Int?
    
    // Media Meta Data
    var artist: String = "Default"
    var title: String = "Default"
    var duration: String = "Default"
    fileprivate var imageName: String = ""
    
    // Actual Media URL bookmark
    var mediaBookmark: Data = Data()
    
    // Media source
    var source: Source?
    
    // User Preferences
    var isFavorite: Bool?
    
    // Owner Preferences
    var isFeatured: Bool?

    // Enum registering supported input streams for media
    enum Source: String, CaseIterable, Codable {
        case digitalFile = "DigitalFile"
        case youtube = "Youtube"
    }
    
    init(artist: String, title: String, duration: String) {
        self.artist = artist
        self.title = title
        self.duration = duration
    }
    
    func artistFormatted() -> String {
        return self.artist
    }
}

