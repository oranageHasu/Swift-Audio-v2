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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        //self.userData.addMedia(self.mediaFileManager.processFolder(with: url))
    }
    
    func directoryPickerDismissed() {
        print("Prompt dismissed.")
    }
}

