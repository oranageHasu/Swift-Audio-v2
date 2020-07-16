//
//  PlayerViewController.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-13.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var songImage: UIImageView!
    
    var currentSong: Media?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial screen setup
        initializePlayer()
    }
    
    func initializePlayer() {
        if let song = currentSong {
            print("\(song.artist)")
            artistLabel.text = song.artist
            titleLabel.text = song.title
        }
    }
}
