//
//  DocumentPickerViewController.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-11.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import Foundation
import UIKit
import CoreServices

class DocumentPickerViewController: UIDocumentPickerViewController {
    private let onDismiss: () -> Void
    private let onPick: (URL) -> ()
    
    init(onPick: @escaping (URL) -> Void,
         onDismiss: @escaping () -> Void) {
        
        self.onDismiss = onDismiss
        self.onPick = onPick
        
        // For just mp3s
        // super.init(documentTypes: ["public.audio"], in: .import)
        super.init(documentTypes: [kUTTypeFolder as String], in: .open)
        
        // allowsMultipleSelection = true
        delegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

//MARK: UIDocumentPickerDelegate
extension DocumentPickerViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        onPick(urls.first!)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        onDismiss()
    }
    
}
