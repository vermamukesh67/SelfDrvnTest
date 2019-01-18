//
//  BookTableViewCell.swift
//  SelfDrvnMobileTest
//
//  Created by Verma Mukesh on 18/01/19.
//  Copyright © 2019 Verma Mukesh. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    @IBOutlet weak var imgBookCover: UIImageView!
    
    @IBOutlet weak var lblBookAuthorName: UILabel!
    @IBOutlet weak var lblBookCoverName: UILabel!
    @IBOutlet weak var lblBookName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
