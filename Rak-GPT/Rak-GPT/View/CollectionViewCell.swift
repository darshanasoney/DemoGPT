//
//  CollectionViewCell.swift
//  Rak-GPT
//
//  Created by Macbook Pro on 18/05/25.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewSuper: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPlatform: UILabel!
    
    var item : Plan?
    var onEditClicked : ((Plan) -> Void)?
    var onGetAnswerClicked : ((Plan) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func populate(plan: Plan) {
        self.item = plan
        self.viewSuper.layer.cornerRadius = 8
        self.lblTitle.text = plan.title
        self.lblPlatform.text = plan.descriptor
    }
    
    @IBAction func editPromptTapped(_ sender: UIButton) {
        guard let item = item else { return }
        
        onEditClicked?(item)
        
    }
    
    @IBAction func getAnswerTapped(_ sender: UIButton) {
        guard let item = item else { return }
        
        onGetAnswerClicked?(item)
    }
    
}
