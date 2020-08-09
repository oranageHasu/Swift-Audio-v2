//
//  SpotifyService.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-31.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import UIKit

protocol SpotifyServiceDelegate {
    func connected(_ spotifyService: SpotifyService)
    func disconnected(_ spotifyService: SpotifyService)
    func playerStateChanged(_ spotifyService: SpotifyService, _ media: Media)
}

// Global SpotifyService instance
// Acts as a wrapper for the Spotify App Remote
var sharedSpotifyService = SpotifyService()

class SpotifyService: NSObject {
    
    static private let kAccessTokenKey = "access-token-key"
    private let redirectUri = URL(string:"spotify-ios-swift-audio://spotify-login-callback")!
    private let clientIdentifier = "1f2df11551c44c8f87b60669ecd2fae7"
    
    // Test Track - Carly Rae Jepson - Call Me Maybe
    private let playURI = "spotify:track:20I6sIOMTCkB6w7ryavxtO"
    
    var delegate: SpotifyServiceDelegate?
    private let dataService = DataService()
    private(set) var playbackPosition: Int = 0
    private(set) var hasAuthorized = false
    private var isPaused = false
    
    // The App Remote for Spotify
    lazy var appRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = sharedSpotifyService
        
        return appRemote
    }()

    // Access Token for the current Spotify User
    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: SpotifyService.kAccessTokenKey)
            
            appRemote.connectionParameters.accessToken = accessToken
        }
    }
    
    public func invokeSpotifyApp() {
        isPaused = false
        appRemote.authorizeAndPlayURI("")
        appRemote.delegate = sharedSpotifyService
    }
    
    public func authorize(from url: URL) -> [String : String]? {
        hasAuthorized = true
        return appRemote.authorizationParameters(from: url)
    }
    
    public func connect() {
        appRemote.connect()
    }
    
    public func disconnect() {
        appRemote.disconnect()
        delegate?.connected(sharedSpotifyService)
    }
    
    public func pause() {
        appRemote.playerAPI?.pause({ (value, error) in
            print("To Do: Pause.")
            self.isPaused.toggle()
        })
    }
    
    public func resume() {
        appRemote.playerAPI?.resume({ (value, error) in
            print("To Do: Resume.")
        })
    }
    
    public func nextSong() {
        appRemote.playerAPI?.skip(toNext: { (value, error) in
            print("To Do: Skip.")
        })
    }
    
    public func prevSong() {
        appRemote.playerAPI?.skip(toPrevious: { (value, error) in
            if let error = error {
                print(error)
            }
            print("To Do: Previous.")
        })
    }
    
    public func toggleShuffle(_ shuffle: Bool) {
        appRemote.playerAPI?.setShuffle(shuffle, callback: { (value, error) in
            print("To Do: Shuffle")
        })
    }
    
    public func toggleRepeat(_ repeat: Bool) {
        appRemote.playerAPI?.setRepeatMode(SPTAppRemotePlaybackOptionsRepeatMode.track, callback: { (value, error) in
            print("To Do: Repeat")
        })
    }
}

extension SpotifyService: SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        // Connection was successful, you can begin issuing commands
        self.appRemote.playerAPI?.delegate = sharedSpotifyService
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
          if let error = error {
            debugPrint(error.localizedDescription)
          }
        })
        
        delegate?.connected(sharedSpotifyService)
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("ERROR -- SpotifyService - Spotify App Remote failed a connection attempt.")
        print(error!)
        delegate?.disconnected(sharedSpotifyService)
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("ERROR -- SpotifyService - Spotify App Remote disconnected.")
        print(error!)
        delegate?.disconnected(sharedSpotifyService)
    }

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {

        // The Spotify App Remote triggers state change when paused
        // We want to ignore this
        if !playerState.isPaused {
            
            // Check if we were previously paused, if so unpause
            // Doing this because PlayerStateDidChange triggers after the Resume event
            if isPaused {
                isPaused.toggle()
            } else {
                // Create a Media instance for the UI
                // To Do: This shouldn't cause duplicates...
                let media = Media(context: dataService.context)
                
                media.artist = playerState.track.artist.name
                media.title = playerState.track.name
                media.duration = Double(playerState.track.duration) / 1000
                media.albumName = playerState.track.album.name
                
                playbackPosition = playerState.playbackPosition
                
                print("Spotify started playing: \(media)")
                delegate?.playerStateChanged(sharedSpotifyService, media)
            }
            
        }
        
    }
    
}
