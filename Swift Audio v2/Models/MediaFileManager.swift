//
//  MediaFileManager.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-11.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import UIKit
import CoreServices
import AVKit

struct MediaFileManager {
    
    let dataService = DataService()
    
    func processFolder(with url: URL) -> [Media] {
        var mediaFromNetwork: [Media] = []
        var error: NSError? = nil
        
        guard url.startAccessingSecurityScopedResource() else {
            
            // Failure!
            print("Failed accessing Directory.")
            return mediaFromNetwork
            
        }
        
        // Ensure the security-scope resource is released once finished
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Use File Coordination for reading the URLs contents
        NSFileCoordinator().coordinate(readingItemAt: url, error: &error, byAccessor: { (url) in
            
            let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
            var tempMedia: Media
            var index = 0

            // Get an enumerator for the Directory's content
            guard let fileList =
                FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys) else {
                    print("ERROR - Unable to access contents of \(url.path)")
                    return
            }
            
            for case let file as URL in fileList {
                
                // Act on the file!
                // For now, simply parse the file name, build a simple Media instance, and display that
                // We'll do better next iteration
                let filename = file.lastPathComponent
                let split = filename.components(separatedBy: " - ")
                
                if (split.count == 2) {
                    var removeCharAmt = 4
                    if split[0].contains(".flac") {
                        removeCharAmt = 5
                    }
                    
                    let songNameWithoutExt = String(split[1].dropLast(removeCharAmt))
     
                    do {
                        // let playerItem = AVPlayerItem(url: file)
                        // print("Meta Data: \(playerItem.asset.metadata)")
                        
                        tempMedia = self.dataService.addMedia(artist: split[0], title: songNameWithoutExt, duration: 0.0, bookmark: try file.bookmarkData())
                        mediaFromNetwork.append(tempMedia)
                    } catch {
                        print("Error creating bookmark.")
                    }
                    
                    index += 1
                }
            }
            
            // Save the Library
            self.dataService.saveLibrary()
        })
                
        return mediaFromNetwork
    }
}
