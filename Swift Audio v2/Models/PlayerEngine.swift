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
    
    // The player engine can be running the show using AVAudioPlayer
    // Alternatively, the User could be playing Spotify content (and potentially other 3rd party service content)
    // Keep track of our "outsource state" here
    private(set) var isOutsourced = false
    
    // Media Cache
    private(set) var currentSong: Media?
    
    var delegate: PlayerEngineDelegate?
    
    //MARK: - Public Methods
    func takeOwnership() {
        isPaused = false
        isOutsourced = false
    }
    
    func engagePlayer(forSong media: Media?) {
        currentSong = media
        player.delegate = self
        
        if !isOutsourced {
            engagePlayer()
        } else {
            engagePlayerSpotify()
        }
    }
    
    func engagePlayerForSpotify() {
        isOutsourced = true
        sharedSpotifyService.delegate = self
        
        if !sharedSpotifyService.hasAuthorized {
            
            // First Time Spotify Authorization
            sharedSpotifyService.invokeSpotifyApp()
            
        } else if !sharedSpotifyService.appRemote.isConnected {
            
            // Authorize with Spotify (if required) and then resume playing
            sharedSpotifyService.invokeSpotifyApp()
            sharedSpotifyService.resume()
            
        }
    }
    
    func stopSong() {
        if isPlaying() {
            if isOutsourced {
                sharedSpotifyService.pause()
                isPaused = true
            } else {
                player.stop()
                isPaused = false
            }
        }
    }
    
    func lastSong() {
        if isOutsourced {
            sharedSpotifyService.prevSong()
        } else {
            playSong()
        }
    }
    
    func nextSong() {
        if isOutsourced {
            sharedSpotifyService.nextSong()
        } else {
            playSong()
        }
    }
    
    func playAt(time: TimeInterval) {
        player.currentTime = time
    }
    
    func beginSkip(_ direction: Direction) {
        skipTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if direction == Direction.fastforward {
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
        
        if isOutsourced {
            sharedSpotifyService.toggleShuffle(isShuffleOn)
        }
    }
    
    func toggleRepeat() {
        isRepeatOn.toggle()

        if isOutsourced {
            sharedSpotifyService.toggleRepeat(isRepeatOn)
        }
    }
    
    func isPlaying() -> Bool {
        return player.isPlaying || (isOutsourced && !isPaused)
    }
    
    //MARK: - Private Methods
    private func engagePlayer() {
        isOutsourced = false
        
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
    
    private func engagePlayerSpotify() {
        if (!isPaused) {
            sharedSpotifyService.pause()
        } else {
            sharedSpotifyService.resume()
            startPlayerTimer()
        }
        
        isPaused.toggle()
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
                        isPaused = false
                        songDuration = player.duration
                        
                        // Playtime timer
                        startPlayerTimer()
                        
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
    
    private func playSpotifySong(at playbackPosition: Int, for song: Media) {
        currentSong = song
        isPaused = false
        
        // Stack state
        playTime = Double(playbackPosition) / 1000
        songDuration = song.duration
        
        // Start the Player Timer
        startPlayerTimer()
        
        // Let everyone know what magic just went down.
        delegate?.newSongStarted(song)
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
        } else if isOutsourced && !isPaused {
            playTime += playtimeTimer.timeInterval
            delegate?.playtimeHasChanged(playTime)
        } else {
            playtimeTimer.invalidate()
        }
    }
    
    private func startPlayerTimer() {
        // Always invalidate the timer before using it
        if let timer = playtimeTimer {
            timer.invalidate()
        }
    
        playtimeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.updatePlayTime()
        }
    }
}

//MARK: - AvAudioPlayer Delegate Methods
extension PlayerEngine: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        nextSong()
    }
    
}

//MARK: - SpotifyService delegagte
extension PlayerEngine: SpotifyServiceDelegate {
    
    func connected(_ spotifyService: SpotifyService) {
        print("PlayerEngine - Spotify Connected.")
    }
    
    func disconnected(_ spotifyService: SpotifyService) {
        print("PlayerEngine - Spotify Disconnected.")
        
        if isOutsourced {
            currentSong = nil
        }
    }
    
    func playerStateChanged(_ spotifyService: SpotifyService, _ media: Media) {
        playSpotifySong(at: spotifyService.playbackPosition, for: media)
    }
    
}
