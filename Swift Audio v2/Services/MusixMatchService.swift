//
//  MusixMatchService.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-26.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol MusixMatchServiceDelegate
{
    func songLyricsAvailable(lyrics: String)
}

struct MusixMatchService {
    
    let baseURL = "https://api.musixmatch.com/ws/1.1/"
    let apiKey = "f4745b398560695e67000526784a30d6"
    
    var delegate: MusixMatchServiceDelegate?
    
    func getTrackLyrics(for trackId: Int) {
        let parameters: [String : String] = [
            "format" : "json",
            "callback" : "callback",
            "track_id" : String(trackId),
            "apikey" : apiKey
        ]
        
        Alamofire.request(baseURL + "track.lyrics.get", method: .get, parameters: parameters).responseJSON { (response) in
            
            if response.result.isSuccess {
                let songJSON: JSON = JSON(response.result.value!)
                let lyricURL = songJSON["message"]["body"]["lyrics"]["pixel_tracking_url"].stringValue
                let lyrics = songJSON["message"]["body"]["lyrics"]["lyrics_body"].stringValue.replacingOccurrences(of: "\n", with: "")
                
                if lyrics.count > 0 {
                    //self.delegate?.songLyricsAvailable(lyrics: lyrics)
                    print("Lryics URL: \(lyricURL)")
                }
            } else {
                print("HTTP request failed.")
            }
        }
    }
}
