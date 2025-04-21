//
//  UIView+Extension.swift
//  EvolveAI
//
//  Created by Vikram Kunwar on 03/10/23.
//

import UIKit

extension UIView{
    
    @IBInspectable var cornerRadius: CGFloat {
        get {return self.cornerRadius}
        set{
            self.layer.cornerRadius = newValue
        }
        
        
        
        
    }
    
    @IBInspectable var shadow: CGFloat {
        get {return self.shadow}
        set{
            self.layer.cornerRadius = newValue
        }
        
        
        
        
    }
}


