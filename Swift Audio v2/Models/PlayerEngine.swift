//
//  PlayerEngine.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-18.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import Foundation
import AVKit

protocol PlayerEngineDelegate {
    func playtimeHasChanged(_ playTime: TimeInterval)
    func newSongStarted(_ media: Media)
}

class PlayerEngine {
    
    // Audio States
    var isShuffleOn = false
    var isRepeatOn = false
    var isPaused = false
    var isPlaying = false
    
    // Player
    var player: AVAudioPlayer!
    var playTime: TimeInterval = 0.0
    var songDuration: TimeInterval = 0.0
    var timer: Timer!
    
    // Media
    private(set) var currentSong: Media?
    
    // Delegate
    var delegate: PlayerEngineDelegate?
    
    //MARK: - Player related methods
    func engagePlayer(forSong media: Media?) {
        currentSong = media
        
        // Engage the Media Player, allowing this engine to decide what to do based on its state.
        if player == nil || !player.isPlaying {
            
            if isPaused {
              resumeSong()
            } else {
                playSong()
            }
            
        } else {
            pauseSong()
        }
    }
    
    private func playSong() {
        // Initialize the Audio Player
        if let song = currentSong {
            var isStale: Bool = false
            var error: NSError? = nil

            do {
                let url =  try URL(resolvingBookmarkData: song.mediaBookmark!, bookmarkDataIsStale: &isStale)
                
                print("File URL: \(url)")
                guard url.startAccessingSecurityScopedResource() else {
                    // Failure!
                    print("Failed accessing URL.")
                    return
                }
                
                // Ensure the security-scope resource is released once finished
                defer { url.stopAccessingSecurityScopedResource() }
                
                // Use File Coordination for reading the URLs contents
                NSFileCoordinator().coordinate(readingItemAt: url, error: &error, byAccessor: { (url) in
                    do {
                        player = try AVAudioPlayer(contentsOf: url)
                        
                        // Play the song
                        player.play()
                        
                        // Stack state
                        isPlaying = player.isPlaying
                        isPaused = false
                        songDuration = player.duration
                        
                        // Playtime timer
                        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                            self.updatePlayTime()
                        }
                        
                        // Let everyone know what magic just went down.
                        delegate?.newSongStarted(song)
                    } catch {
                        print("Error Playing while loading media.")
                    }
                })
            } catch {
                print(error)
            }
        }
    }
    
    private func pauseSong() {
        player.pause()
        isPaused.toggle()
        playTime = player.currentTime
    }
    
    private func resumeSong() {
        player.play()
        isPaused = false
    }
    
    func stopSong() {
        if isPlaying {
            player.stop()
            isPlaying = false
            isPaused = false
        }
    }
    
    func lastSong() {
        // Stop playing the current song
        stopSong()
        
        // Play the new song
        playSong()
    }
    
    func nextSong() {
        // Stop playing the current song
        stopSong()

        // Play the new song
        playSong()
    }
    
    func updatePlayTime() {
        if isPlaying {
            if let currentTime = player?.currentTime {
                playTime = currentTime
                delegate?.playtimeHasChanged(playTime)
            }
        } else {
            timer.invalidate()
        }
    }
}
