//
//  PlaneView.swift
//  Surf
//
//  Created by 孔祥波 on 8/3/16.
//  Copyright © 2016 abigt. All rights reserved.
//

import UIKit
func  DegreesToRadians(degrees:CGFloat) ->CGFloat
{
    return degrees * CGFloat(Float.pi) / 180;
};
class PlaneView: UIView {

    var image:UIImage
    required init?(coder aDecoder: NSCoder) {
        image =   UIImage.init(named: "plane")!
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    override func draw(_ rect: CGRect) {
        
        //image.drawAtPoint(self.center)
        let ctx:CGContext = UIGraphicsGetCurrentContext()!
        ctx.saveGState();
        ctx.translateBy(x: 0, y: rect.height)
        ctx.scaleBy(x: 1.0, y: -1.0);
       // CGContextRotateCTM(ctx, DegreesToRadians(45));

        let          myShadowOffset = CGSize (width:0, height: 10);
        //CGContextSetShadow (ctx, myShadowOffset, 10);
        ctx.setShadow (offset: myShadowOffset, blur: 5, color: UIColor.gray.cgColor);
        //image.drawInRect(rect)
        
        ctx.setFillColor(UIColor.white.cgColor);
        ctx.clip(to: rect, mask: image.cgImage!);
        ctx.fill(self.bounds);
        
       
        ctx.restoreGState();

    }
    

}
