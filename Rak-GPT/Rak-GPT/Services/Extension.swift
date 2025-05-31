//
//  extension.swift
//  Rak-GPT
//
//  Created by Macbook Pro on 20/05/25.
//

import UIKit

extension UIViewController {
    
    func pushViewController(identifier: String) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: identifier) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
