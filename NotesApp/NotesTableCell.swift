//
//  NotesTableCell.swift
//  NotesApp
//
//  Created by Vikram Kunwar on 17/04/25.
//

import UIKit

class NotesTableCell: UITableViewCell {
    
    @IBOutlet weak var title : UILabel!
    @IBOutlet weak var date : UILabel!
    
    @IBOutlet weak var pinned: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
