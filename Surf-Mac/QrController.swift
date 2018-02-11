//
//  ViewController.swift
//  testReadScan
//
//  Created by 孔祥波 on 08/12/2016.
//  Copyright © 2016 Kong XiangBo. All rights reserved.
//

import Cocoa
/// The tunnel delegate protocol.
import Foundation
import CoreGraphics
import AVFoundation
@objc public protocol BarcodeScanDelegate: class {
    func barcodeScanDidScan(controller: QrController, configString:String)
    func barcodeScanCancelScan(controller: QrController)
    
}


public class QrController: NSObject,AVCaptureVideoDataOutputSampleBufferDelegate{
    
    
    let kScanQRCodeQueueName = "ScanQRCodeQueueName"
    var captureSession: AVCaptureSession?
    var input:AVCaptureScreenInput?
    //AVCaptureOutput* output;
    var lastResult : Bool!
    var startDate:Date = Date()
    weak var delegate:BarcodeScanDelegate?
    
   
    var timeOut = 5.0
    
    @IBAction func cancleAction(_ sender: AnyObject) {
        guard let d = self.delegate else{
            return
        }
        //self.navigationController?.popViewController(animated:(<#T##animated: Bool##Bool#>)
        d.barcodeScanCancelScan(controller: self)
    }
    func  startReading() -> Bool{
        //        let error: NSError?
        if captureSession == nil {
            //let captureDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            
            //let input = try! AVCaptureDeviceInput(device: captureDevice)
            
            
            input = AVCaptureScreenInput.init(displayID: CGMainDisplayID())
            input?.capturesMouseClicks = false
            input?.minFrameDuration = CMTimeMake(1, 60);
            input?.scaleFactor = 0.5
            input?.cropRect = NSScreen.screens.first!.frame
            //self.input.cropRect = [self screenRect];
            captureSession = AVCaptureSession()
            
            captureSession?.sessionPreset = AVCaptureSession.Preset.low
            captureSession?.addInput(input!)
            
          ///let captureMetadataOutput = AVCaptureMetadataOutput()
            let captureMetadataOutput = AVCaptureVideoDataOutput()
            captureMetadataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String : Int(kCVPixelFormatType_32BGRA)]
            captureSession?.addOutput(captureMetadataOutput)
            
            let dispatchQueue = DispatchQueue(label:kScanQRCodeQueueName)
            captureMetadataOutput.setSampleBufferDelegate(self, queue: dispatchQueue)
            
        }
        
        
        
        
        
        if captureSession?.isRunning == false {
            startDate = Date()
            captureSession?.startRunning()
        }
        
        
        return true
    }
    
    func stopReading(){
        captureSession?.stopRunning()
        
    }
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!){
        
    
        
        let  imageBuffer:CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!;
        
        
        CVPixelBufferLockBaseAddress(imageBuffer,CVPixelBufferLockFlags(rawValue: 0));        // Lock the image buffer
        
        let  baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        let width = CVPixelBufferGetWidth(imageBuffer);
        let height = CVPixelBufferGetHeight(imageBuffer);
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB();
        
        //kCGBitmapByteOrder32Little
        //CGBitmapInfo.init(rawValue: <#T##UInt32#>)
        
        let info = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        let newContext:CGContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace,bitmapInfo: info )!;// | kCGImageAlphaPremultipliedFirst
        let newImage:CGImage = newContext.makeImage()!;
    
        
        //CGColorSpaceRelease(colorSpace);
        CVPixelBufferUnlockBaseAddress(imageBuffer,CVPixelBufferLockFlags(rawValue: 0));
        
        //let bitmapRep :NSBitmapImageRep = NSBitmapImageRep.init(cgImage: newImage)
        //let nsImage  = NSImage.init(cgImage: newImage, size: CGSize.init(width: width, height: height))
        //let imageCompression :CGFloat = 0.5;
        
        
        
        self.scanImage(newImage)
        
    }
    
    
    func reportScanResult(result:String!){
        stopReading()
        
        
        guard let d = self.delegate else{
            return
        }
        let q = DispatchQueue.main
        q.async {[weak self] in
             d.barcodeScanDidScan(controller: self!, configString: result)
        }
       
    }
    
    
    func  scanImage(_ image:CGImage){
        let ciImage:CIImage = CIImage(cgImage:image )
        var message:String = ""
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        
        let features = detector!.features(in: ciImage)
        
        if features.count > 0{
            
            for feature in features as! [CIQRCodeFeature]{
                message += feature.messageString!
            }
           print(message)
        
           
        }
        if message.isEmpty {
            if  Date().timeIntervalSince(startDate) > timeOut {
                captureSession!.stopRunning()
                guard let d = self.delegate else{
                    return
                }
                let q = DispatchQueue.main
                q.async {[weak self] in
                    d.barcodeScanCancelScan(controller: self!)
                }
                
            }else {
                
            }
            
        }else {
            reportScanResult(result:message)
        }
//

    }
    
    deinit {
        print("Qr Scan deinit")
    }
  
   
}

