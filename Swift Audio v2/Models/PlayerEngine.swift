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

// Global PlayerEngine instance
// This allows us to move around screens while maintaining state
var sharedPlayerEngine = PlayerEngine()

class PlayerEngine: NSObject {
    
    // Audio States
    private(set) var isShuffleOn = false
    private(set) var isRepeatOn = false
    private(set) var isPaused = false
    
    // Player
    private var player = AVAudioPlayer()
    private var playTime: TimeInterval = 0.0
    private(set) var songDuration: TimeInterval = 0.0
    private var playtimeTimer: Timer!
    private var skipTimer: Timer!
    
    // Media Cache
    private(set) var currentSong: Media?
    
    var delegate: PlayerEngineDelegate?
    
    //MARK: - Public Methods
    func engagePlayer(forSong media: Media?) {
        currentSong = media
        player.delegate = self
        
        // Engage the Media Player, allowing this engine to decide what to do based on its state.
        if !player.isPlaying {
            
            if isPaused {
              resumeSong()
            } else {
                playSong()
            }
            
        } else {
            pauseSong()
        }
    }
    
    func stopSong() {
        if player.isPlaying {
            player.stop()
            isPaused = false
        }
    }
    
    func lastSong() {
        playSong()
    }
    
    func nextSong() {
        playSong()
    }
    
    func playAt(time: TimeInterval) {
        player.currentTime = time
    }
    
    func beginSkip(_ direction: Direction) {
        skipTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if direction == Direction.fastforward {
                print(self.player.currentTime)
                self.playAt(time: self.player.currentTime+5)
            } else {
                self.playAt(time: self.player.currentTime-5)
            }
        }
    }
    
    func endSkip() {
        skipTimer.invalidate()
    }
    
    func toggleShuffle() {
        isShuffleOn.toggle()
    }
    
    func toggleRepeat() {
        isRepeatOn.toggle()
    }
    
    func isPlaying() -> Bool {
        return player.isPlaying
    }
    
    //MARK: - Private Methods
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
                        isPaused = false
                        songDuration = player.duration
                        
                        // Playtime timer
                        playtimeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
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
    
    private func updatePlayTime() {
        if player.isPlaying {
            delegate?.playtimeHasChanged(player.currentTime)
        } else {
            playtimeTimer.invalidate()
        }
    }
}

//MARK: - AvAudioPlayer Delegate Methods
extension PlayerEngine: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        nextSong()
    }
    
}
