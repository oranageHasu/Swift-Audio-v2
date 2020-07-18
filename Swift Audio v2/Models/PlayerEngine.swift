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
}

class PlayerEngine {
    
    //MARK: - Variable Declarations
    // Temp Variables
    var songs = ["Men At Work - Who Can It Be Now.flac","The Reklaws - Old Country Soul.mp3"]
    var currentSongIndex: Int = 0
    let dot = "."
    let mp3 = "mp3"
    let flac = "flac"
    
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
    
    // Delegate
    var delegate: PlayerEngineDelegate?
    
    //MARK: - Player related methods
    func engagePlayer() {
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
        var songExt = ""
        var songName = ""
        
        if songs[currentSongIndex].hasSuffix(mp3) {
            songExt = mp3
        } else {
            songExt = flac
        }
        
        songName = String(songs[currentSongIndex].dropLast(songExt.count+1))
        
        let path = Bundle.main.path(forResource: songName, ofType: songExt)!
        let url = URL(fileURLWithPath: path)
        
        do {
            // Initialize the Audio Player
            player = try AVAudioPlayer(contentsOf: url)
            
            // Play the song
            player.play()
            
            // Stack state
            isPlaying = player.isPlaying
            isPaused = false
            
            songDuration = player.duration
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                self.updatePlayTime()
            }
        } catch {
            print("Error Playing Music.")
            print(error)
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
        
        // Reset the Curr Index back to Array length if the user hits the start of the fake library
        if currentSongIndex > 0 {
            currentSongIndex -= 1
        } else {
            currentSongIndex = songs.count-1
        }
        
        // Play the new song
        playSong()
    }
    
    func nextSong() {
        // Stop playing the current song
        stopSong()

        // Reset the Curr Index back to 0 if the user hits the end of the fake library
        if currentSongIndex < songs.count-1 {
            currentSongIndex += 1
        } else {
            currentSongIndex = 0
        }
        
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
