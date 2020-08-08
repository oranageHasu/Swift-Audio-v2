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
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func saveFile(url: URL, fileName: String){
        if let docUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let desURL = docUrl.appendingPathComponent("\(fileName).\(url.pathExtension)")
              
            do {
                try FileManager.default.copyItem(at: url, to: desURL)
            } catch {
                print(error)
            }
        }
    }
    
    func listFiles() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            print("Current Document Folder:")
            print(fileURLs)
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    func processFolder(with url: URL) -> [Media] {
        var mediaFromNetwork: [Media] = []
        var error: NSError? = nil
        
        guard url.startAccessingSecurityScopedResource() else {
            print("Failed accessing Directory.")
            return mediaFromNetwork
        }
        
        // Ensure the security-scope resource is released once finished
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Use File Coordination for reading the URLs contents
        NSFileCoordinator().coordinate(readingItemAt: url, error: &error, byAccessor: { (url) in
            let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey]

            // Get an enumerator for the Directory's content
            guard let fileList =
                FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys) else {
                    print("ERROR - Unable to access contents of \(url.path)")
                    return
            }
            
            for case let file as URL in fileList {
                
                do {
                    // Get the song metadata
                    let playerItem = AVPlayerItem(url: file)
                    let metadata = playerItem.asset.metadata
                    
                    // Add a new Media item to the database
                    // To Do: Handle duplicates
                    let media = Media(context: dataService.context)

                    // Create a filesystem bookmark for this song
                    media.mediaBookmark = try file.bookmarkData()
                    
                    // Track this file's URL (this is incase we want to copy it locally)
                    media.filePath = file.absoluteURL.absoluteString
                    
                    // Process the metadata
                    for item in metadata {

                        guard let key = item.commonKey?.rawValue, let value = item.value else{
                            continue
                        }
                        
                        switch key {
                            case "title" : media.title = value as? String
                            case "artist": media.artist = value as? String
                            case "albumName": media.albumName = value as? String
                            case "type": media.type = value as? String
                            case "publisher": media.publisher = value as? String
                            case "artwork" where value is Data : media.artwork = value as? Data
                            default:
                                print("Unknown: \(value) For Key: \(key)")
                            continue
                        }
                    }
                    
                    mediaFromNetwork.append(media)
                } catch {
                    print("ERROR - MediaFileManager.processFolder() - Error processing music file.")
                    print(error)
                }
            }
            
            // Save the Library
            self.dataService.saveLibrary()
        })
                
        return mediaFromNetwork
    }
}
