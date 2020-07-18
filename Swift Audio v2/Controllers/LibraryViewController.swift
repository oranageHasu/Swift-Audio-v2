//
//  ViewController.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-10.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
    
    @IBOutlet weak var groupSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var currentSong: Media?
    var mediaManager = MediaFileManager()
    var media: [Media] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // get a reference to the Player ViewController
        let player = segue.destination as! PlayerViewController
        
        // Supply the song to play
        player.currentSong = currentSong
    }
    
    @IBAction func importDirectoryPressed(_ sender: UIButton) {
        let picker = DocumentPickerViewController(
            onPick: self.directorySelected,
            onDismiss: self.directoryPickerDismissed
        )
        
        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
    }
    
    func directorySelected(url: URL) {
        print("File URL: \(url)")
        
        // Clear the current Media collection
        self.media = []

        // Display an progress indicator
        let alert = UIAlertController(title: nil, message: "Loading music...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 70, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        // Use a Background Thread to read in the Media
        // Note: We're creating Bookmarks to access the songs.  This can be long-running
        DispatchQueue.global(qos: .background).async {
            self.media = self.mediaManager.processFolder(with: url)

            DispatchQueue.main.async {
                // Dimiss the loading indicator
                alert.dismiss(animated: true, completion: nil)
                
                // Reload the table
                self.tableView.reloadData()
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
        
        // Update the Tableview (should now be empty)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func directoryPickerDismissed() {
        print("Prompt dismissed.")
    }
}

//MARK: - TableView Datasource
extension LibraryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.media.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mediaItem = media[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! MediaItemViewCell
        
        cell.artistLabel.text = mediaItem.artist
        cell.songTitleLabel.text = mediaItem.title
        cell.songDurationLabel.text = mediaItem.duration
        
        return cell
    }
}

//MARK: - TableView Delegate
extension LibraryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set the current Media selection
        currentSong = media[indexPath.row]
        
        // Perform Touch interaction with the media here
        self.performSegue(withIdentifier: Constants.playerSegue, sender: self)
    }
}
