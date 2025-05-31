//
//  UIButton-Extension.swift
//  Rak-GPT
//
//  Created by Macbook Pro on 20/05/25.
//

import UIKit

@IBDesignable

class RaKButton : UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = layer.borderColor == UIColor.clear.cgColor ? 0 : 1
        }
    }
}


@IBDesignable

class RakView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
        
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = layer.borderColor == UIColor.clear.cgColor ? 0 : 1
        }
    }
    
}

@IBDesignable

class RakImageView: UIImageView {
    
    @IBInspectable var backShadow: CGFloat = 0 {
        
        didSet {
            self.layer.shadowColor = UIColor.gray.cgColor
            self.layer.shadowOffset = CGSize(width: -4, height: 4)
            self.layer.shadowOpacity = 0.5
        }
        
    }
    
}
