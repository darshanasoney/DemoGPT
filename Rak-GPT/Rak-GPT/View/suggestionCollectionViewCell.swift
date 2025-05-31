//
//  CollectionViewCell.swift
//  Rak-GPT
//
//  Created by Macbook Pro on 18/05/25.
//

import UIKit

class suggestionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewSuper: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func populate(plan: Plan) {
        
        self.lblTitle.text = plan.title
    }
}
