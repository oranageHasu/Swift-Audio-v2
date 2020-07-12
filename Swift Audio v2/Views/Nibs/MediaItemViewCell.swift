//
//  MediaItemViewCell.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-12.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import UIKit

class MediaItemViewCell: UITableViewCell {

    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songDurationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
