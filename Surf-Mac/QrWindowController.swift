//
//  QrWindowController.swift
//  Surf
//
//  Created by 孔祥波 on 08/12/2016.
//  Copyright © 2016 abigt. All rights reserved.
//

import Cocoa
import SFSocket
import CoreGraphics
import AppKit
import Xcon
class QrWindowController: NSWindowController {

    @IBOutlet var imageView: NSImageView!
    var proxy:SFProxy!
    override func windowDidLoad() {
        super.windowDidLoad()
        generateQRCodeScale(scale: 1.0)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    func generateQRCodeScale(scale:CGFloat){
        //
        // ss://aes-256-cfb:fb4b532cb4180c9037c5b64bb3c09f7e@108.61.126.194:14860"
        
        let base64Encoded = proxy.base64String()
        let stringData =  base64Encoded.data(using: .utf8, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        guard let f = filter else {
            return
        }
        f.setValue(stringData, forKey: "inputMessage")
        f.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let image = f.outputImage else {
            return
        }
        
        let cgImage = CIContext(options:nil).createCGImage(image, from:image.extent )
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB();
        let bytesPerRow =  2560
        let info = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        let newContext:CGContext = CGContext(data: nil, width: 500 , height: 500, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace,bitmapInfo: info )!;
        newContext.interpolationQuality = .none
        newContext.draw(cgImage!, in: CGRect.init(x: 0, y: 0, width: 500, height: 500))
        let newImage:CGImage = newContext.makeImage()!;
        let nsImage = NSImage.init(cgImage:newImage, size: CGSize.init(width: 250 , height: 250))
        self.imageView.image = nsImage
        
    
        
    }
}
