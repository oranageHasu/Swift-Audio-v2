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
    
    var mediaManager = MediaFileManager()
    var media: [Media] = [
        Media(artist: "Clay Walker", title: "She Won't Be Lonely Long", duration: "3:48"),
        Media(artist: "Blue Rodeo", title: "Head Over Heels", duration: "2:55")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
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
        media = mediaManager.processFolder(with: url)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    func directoryPickerDismissed() {
        print("Prompt dismissed.")
    }
}


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

extension LibraryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        // Perform Touch interaction with the media here
        
    }
}
