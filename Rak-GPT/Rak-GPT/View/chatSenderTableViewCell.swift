//
//  chatSenderTableViewCell.swift
//  Rak-GPT
//
//  Created by Macbook Pro on 18/05/25.
//

import UIKit

class chatSenderTableViewCell: UITableViewCell {

    @IBOutlet weak var senderTitle: UILabel!
    @IBOutlet weak var senderMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func populate(chat: Chat) {
        let user = DataManager.instsnce.retrieveUser()
        self.senderTitle.text = user?.name
        self.senderMessage.text = chat.message
    }
}
