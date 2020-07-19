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
    
    var playerEngine = PlayerEngine()
    var currentSong: Media?
    
    var timeFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerEngine.delegate = self
        
        // Initial View setup
        initializePlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        playerEngine.engagePlayer(forSong: currentSong)
    }
    
    //MARK: - IBActions
    @IBAction func playPressed(_ sender: UIButton) {
        playerEngine.engagePlayer(forSong: currentSong)
        refreshUI()
    }
    
    @IBAction func stopPressed(_ sender: UIButton) {
        playerEngine.stopSong()
        refreshUI()
        playtimeLabel.text = "00:00"
    }
    
    @IBAction func nextSongPressed(_ sender: UIButton) {
        playerEngine.nextSong()
    }
    
    @IBAction func lastSongPressed(_ sender: UIButton) {
        playerEngine.lastSong()
    }
    
    @IBAction func shufflePressed(_ sender: UIButton) {
        playerEngine.isShuffleOn.toggle()
        toggleImageColor(for: shuffleButton, with: playerEngine.isShuffleOn)
    }
    
    @IBAction func repeatPressed(_ sender: UIButton) {
        playerEngine.isRepeatOn.toggle()
        toggleImageColor(for: repeatButton, with: playerEngine.isRepeatOn)
    }
    
    //MARK: - Private Methods
    private func initializePlayer() {
        if let song = currentSong {
            artistLabel.text = song.artist
            titleLabel.text = song.title
        } else {
            print("ERROR -- PlayerViewController.initializePlayer() - Supplied Media instance is nil.")
        }
    }
    
    private func refreshUI() {
        // Player/Pause button state:
        if playerEngine.isPlaying && !playerEngine.isPaused {
            playButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            playButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        
        // Song metadata related state:
        durationLabel.text = timeIntervalToString(for: playerEngine.songDuration)
        
        if let artwork = playerEngine.currentSong?.artwork {
            songImage.image = UIImage(data: artwork)
            print(songImage.image)
        } else {
            print("no artwork")
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
        
        let timePlayed = playerEngine.playTime / playerEngine.songDuration
        playerSlider.value = Float(timePlayed)
    }
    
    func newSongStarted(_ media: Media) {
        currentSong = media
        refreshUI()
    }
}
