//
//  PlayerViewController.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-13.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import UIKit

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
    
    var currentSong: Media?
    
    var timeFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sharedPlayerEngine.delegate = self
        
        // Initial View setup
        initializePlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sharedPlayerEngine.engagePlayer(forSong: currentSong)
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
    }
    
    @IBAction func nextSongPressed(_ sender: UIButton) {
        sharedPlayerEngine.nextSong()
    }
    
    @IBAction func lastSongPressed(_ sender: UIButton) {
        sharedPlayerEngine.lastSong()
    }
    
    @IBAction func shufflePressed(_ sender: UIButton) {
        sharedPlayerEngine.isShuffleOn.toggle()
        toggleImageColor(for: shuffleButton, with: sharedPlayerEngine.isShuffleOn)
    }
    
    @IBAction func repeatPressed(_ sender: UIButton) {
        sharedPlayerEngine.isRepeatOn.toggle()
        toggleImageColor(for: repeatButton, with: sharedPlayerEngine.isRepeatOn)
    }
    
    //MARK: - Private Methods
    private func initializePlayer() {
        if let song = currentSong {
            artistLabel.text = song.artist
            titleLabel.text = song.title
        } else {
            print("ERROR -- PlayerViewController.initializePlayer() - Supplied Media instance is nil.")
        }
        
        // Stop the current song (if already playing)
        sharedPlayerEngine.stopSong()
    }
    
    private func refreshUI() {
        // Player/Pause button state:
        if sharedPlayerEngine.isPlaying && !sharedPlayerEngine.isPaused {
            playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            playButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        
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
    
    private func toggleImageColor(for button: UIButton!, with state: Bool) {
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
        
        let timePlayed = sharedPlayerEngine.playTime / sharedPlayerEngine.songDuration
        playerSlider.value = Float(timePlayed)
    }
    
    func newSongStarted(_ media: Media) {
        currentSong = media
        refreshUI()
    }
}
