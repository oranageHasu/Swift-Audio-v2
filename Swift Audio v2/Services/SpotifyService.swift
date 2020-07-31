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
    
    // The App Remote for Spotify
    lazy var appRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        
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
        appRemote.authorizeAndPlayURI("")
        appRemote.delegate = self
    }
    
    public func authorize(from url: URL) -> [String : String]? {
        return appRemote.authorizationParameters(from: url)
    }
    
    public func connect() {
        appRemote.connect()
        delegate?.connected(self)
    }
    
    public func disconnect() {
        appRemote.disconnect()
        delegate?.connected(self)
    }
}

extension SpotifyService: SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        // Connection was successful, you can begin issuing commands
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
          if let error = error {
            debugPrint(error.localizedDescription)
          }
        })
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("ERROR -- SpotifyService - Spotify App Remote failed a connection attempt.")
        print(error!)
        delegate?.disconnected(self)
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("ERROR -- SpotifyService - Spotify App Remote disconnected.")
        print(error!)
        delegate?.disconnected(self)
    }

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        let media = Media()
        
        media.artist = playerState.track.artist.name
        media.title = playerState.track.name
        media.duration = Double(playerState.track.duration)
        media.albumName = playerState.track.album.name
        
        print("Spotify started playing: \(media)")
        delegate?.playerStateChanged(self, media)
    }
    
}
