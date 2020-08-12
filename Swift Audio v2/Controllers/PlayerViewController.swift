//
//  PlayerViewController.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-13.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import UIKit
import AVKit
import MarqueeLabel

class PlayerViewController: UIViewController {

    // Player Buttons
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    
    // Media components
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var playtimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var playerSlider: UISlider!
    
    var currentSong: Media? {
        willSet {
            if newValue != nil && sharedPlayerEngine.currentSong == newValue {
                isResumingSong = true
            } else {
                isResumingSong = false
            }
        }
    }
    
    var shouldUseSpotifyService = false
    
    private var musixMatchService = MusixMatchService()
    private var userIsAdjustingSlider = false
    private var isResumingSong = false
    
    private var timeFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sharedPlayerEngine.delegate = self
        musixMatchService.delegate = self
        
        // Initial View setup
        initializePlayer()
        
        //musixMatchService.getTrackLyrics(for: 66976660)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !isResumingSong {
            
            // Determine if we're playing from the library or Spotify
            if shouldUseSpotifyService {
                sharedPlayerEngine.engagePlayerForSpotify()
            } else {
                sharedPlayerEngine.takeOwnership()
                sharedPlayerEngine.engagePlayer(forSong: currentSong)
            }
            
        } else {
            if shouldUseSpotifyService {
                sharedPlayerEngine.engagePlayerForSpotify()
            }
            
            refreshUI()
        }
    }
    
    //MARK: - IBActions
    @IBAction func playPressed(_ sender: UIButton) {
        sharedPlayerEngine.engagePlayer(forSong: currentSong)
        refreshUI()
    }
    
    @IBAction func stopPressed(_ sender: UIButton) {
        sharedPlayerEngine.stopSong()
        refreshUI()
        playtimeLabel.text = "00:00"
        playerSlider.value = 0
    }
    
    @IBAction func nextSongPressed(_ sender: UIButton) {
        sharedPlayerEngine.nextSong()
    }
    
    @IBAction func lastSongPressed(_ sender: UIButton) {
        sharedPlayerEngine.lastSong()
    }
    
    @IBAction func shufflePressed(_ sender: UIButton) {
        sharedPlayerEngine.toggleShuffle()
        toggleImageColor(for: shuffleButton, sharedPlayerEngine.isShuffleOn)
    }
    
    @IBAction func repeatPressed(_ sender: UIButton) {
        sharedPlayerEngine.toggleRepeat()
        toggleImageColor(for: repeatButton, sharedPlayerEngine.isRepeatOn)
    }
    
    @IBAction func currentTimeChanged(_ sender: UISlider) {
        sharedPlayerEngine.playAt(time: Double(sender.value))
    }
    
    @IBAction func sliderTouchUp(_ sender: UISlider) {
        userIsAdjustingSlider = false
    }
    
    @IBAction func sliderDragInside(_ sender: UISlider) {
        userIsAdjustingSlider = true
    }
    
    @IBAction func rewindTouchDown(_ sender: UIButton) {
        sharedPlayerEngine.beginSkip(.rewind)
    }
    
    @IBAction func rewindTouchUp(_ sender: UIButton) {
        sharedPlayerEngine.endSkip()
    }
    
    @IBAction func fastforwardTouchDown(_ sender: UIButton) {
        sharedPlayerEngine.beginSkip(.fastforward)
    }
    
    @IBAction func fastforwardTouchUp(_ sender: UIButton) {
        sharedPlayerEngine.endSkip()
    }
    
    //MARK: - Private Methods
    private func initializePlayer() {
        if let song = currentSong {
            artistLabel.text = song.artist
            titleLabel.text = song.title
        } else if !shouldUseSpotifyService {
            print("ERROR -- PlayerViewController.initializePlayer() - Supplied Media instance is nil.")
        }
        
        // Stop the current song (if already playing)
        if !isResumingSong {
            sharedPlayerEngine.stopSong()
        } else {
            refreshUI()
        }
    }
    
    private func refreshUI() {
        // Player/Pause button state:
        if (sharedPlayerEngine.isPlaying() || sharedPlayerEngine.isOutsourced) && !sharedPlayerEngine.isPaused {
            playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            playButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        
        // Artist/Title
        if let song = sharedPlayerEngine.currentSong {
            artistLabel.text = song.artist
            titleLabel.text = song.title
        }
        
        // Slider Max value
        playerSlider.maximumValue = Float(sharedPlayerEngine.songDuration)
        
        // Song metadata related state:
        durationLabel.text = timeIntervalToString(for: sharedPlayerEngine.songDuration)
        
        if let artwork = sharedPlayerEngine.currentSong?.artwork {
            songImage.image = UIImage(data: artwork)
        } else {
            // Default Artwork
            songImage.image = UIImage(systemName: "hifispeaker")?.withAlignmentRectInsets(UIEdgeInsets(top: -45, left: -45, bottom: -45, right: -45))
            songImage.tintColor = UIColor(cgColor: CGColor(srgbRed: 255.0, green: 255.0, blue: 255.0, alpha: 1))
        }
    }
    
    private func toggleImageColor(for button: UIButton!,_ state: Bool) {
        if state {
            button.tintColor = UIColor.systemBlue
        } else {
            button.tintColor = UIColor.white
        }
    }
    
    private func timeIntervalToString(for timeInterval: TimeInterval) -> String {
        let time = timeFormat.string(from: Date(timeIntervalSince1970: timeInterval))
        return time
    }
}

//MARK: - PlayerEngine delegate
extension PlayerViewController: PlayerEngineDelegate {
    
    func playtimeHasChanged(_ playTime: TimeInterval) {
        playtimeLabel.text = timeIntervalToString(for: playTime)
        
        if !userIsAdjustingSlider {
            playerSlider.value = Float(playTime)
        }
    }
    
    func newSongStarted(_ media: Media) {
        currentSong = media
        refreshUI()
    }
}

//MARK: - MusixMatchService delegate
extension PlayerViewController: MusixMatchServiceDelegate {
    
    func songLyricsAvailable(lyrics: String) {
        print(lyrics)
    }
    
}
