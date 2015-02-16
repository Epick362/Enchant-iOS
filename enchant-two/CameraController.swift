//
//  CameraViewController.swift
//  Enchant
//
//  Created by Filip Hájek on 8.12.2014.
//  Copyright (c) 2014 Enchant. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

enum Status: Int {
    case Preview, Still, Error
}

class CameraController: UIViewController, EnchantCameraDelegate {
    
    @IBOutlet weak var cameraStill: UIImageView!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var cameraCapture: UIButton!
    
    var preview: AVCaptureVideoPreviewLayer?
    
    var enchantUrl: String?
    
    var camera: EnchantCamera?
    var status: Status = .Preview
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.initializeCamera()
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.establishVideoPreviewArea()
    }
    
    func initializeCamera() {
        self.camera = EnchantCamera(sender: self)
    }
    
    func establishVideoPreviewArea() {
        self.preview = AVCaptureVideoPreviewLayer(session: self.camera?.session)
        self.preview?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.preview?.frame = self.cameraPreview.frame
        
        self.cameraPreview.layer.addSublayer(self.preview)
    }
    
    // MARK: Button Actions
    
    @IBAction func captureFrame(sender: AnyObject) {
        if self.status == .Preview {
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.cameraPreview.alpha = 0.0;
            })
            
            self.camera?.captureStillImage({ (image) -> Void in
                if image != nil {
                    // Attempt to create a new enchant
                    
                    println("Uploading image to url: \(self.enchantUrl!)")
                    
                    Enchant(url: self.enchantUrl!).uploadImage(image!, completed: { () -> Void in
                        println("hahah")
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                    
                    self.cameraStill.image = image;
                    
                    UIView.animateWithDuration(0.225, animations: { () -> Void in
                        self.cameraStill.alpha = 1.0;
                    })
                    self.status = .Still
                } else {
                    self.status = .Error
                }
                
                self.cameraCapture.setTitle("Reset", forState: UIControlState.Normal)
            })
        } else if self.status == .Still || self.status == .Error {
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.cameraStill.alpha = 0.0;
                self.cameraPreview.alpha = 1.0;
                self.cameraCapture.setTitle("Capture", forState: UIControlState.Normal)
                }, completion: { (done) -> Void in
                    self.cameraStill.image = nil;
                    self.status = .Preview
            })
        }
    }
    
    // MARK: Camera Delegate
    
    func cameraSessionConfigurationDidComplete() {
        self.camera?.startCamera()
    }
    
    func cameraSessionDidBegin() {
        UIView.animateWithDuration(0.225, animations: { () -> Void in
            self.cameraPreview.alpha = 1.0
            self.cameraCapture.alpha = 1.0
        })
    }
    
    func cameraSessionDidStop() {
        UIView.animateWithDuration(0.225, animations: { () -> Void in
            self.cameraPreview.alpha = 0.0
        })
    }
}


