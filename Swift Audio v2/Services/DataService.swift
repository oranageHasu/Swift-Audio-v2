//
//  DataService.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-18.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import UIKit
import CoreData

struct DataService {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func addMedia(artist: String, title: String, duration: Double, bookmark: Data) -> Media {
        let retval = Media(context: context.self)
        retval.artist = artist
        retval.title = title
        retval.duration = duration
        retval.mediaBookmark = bookmark
        
        return retval
    }
    
    func loadLibrary(with request: NSFetchRequest<Media> = Media.fetchRequest()) -> [Media] {
        var retval: [Media] = []
        
        do {
            retval = try context.fetch(request)
        } catch {
            print(error)
        }
        
        return retval
    }
    
    func saveLibrary() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
}
