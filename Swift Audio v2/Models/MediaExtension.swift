//
//  MediaExtension.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-25.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import Foundation

extension Media {
    
    func songFormatted() -> String {
        var retval = "<No Track Info>"
        
        if let artist = artist {
            retval = artist
            
            if let title = title {
                retval += " - \(title)"
            }
            
        } else if let title = title {
            retval = title
        }
        
        return retval
    }
    
}
