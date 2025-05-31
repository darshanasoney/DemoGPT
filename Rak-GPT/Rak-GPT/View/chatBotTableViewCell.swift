//
//  chatBotTableViewCell.swift
//  Rak-GPT
//
//  Created by Macbook Pro on 18/05/25.
//

import UIKit

class chatBotTableViewCell: UITableViewCell {

    @IBOutlet weak var botMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populate(chat: Chat) {
        self.botMessage.text = chat.message
    }
}
