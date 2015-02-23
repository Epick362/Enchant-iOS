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
import IJProgressView

enum Status: Int {
    case Preview, Still, Error
}

class CameraController: UIViewController, EnchantCameraDelegate {
    
    @IBOutlet weak var cameraStill: UIImageView!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var cameraCapture: UIButton!
    @IBOutlet weak var okayButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var preview: AVCaptureVideoPreviewLayer?
    
    var enchantUrl: String?
    
    var camera: EnchantCamera?
    var status: Status = .Preview
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.initializeCamera()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        view.backgroundColor = UIColor.blackColor()
        self.cameraPreview.backgroundColor = UIColor.blackColor()
        
        self.cameraStill.contentMode = .Center;
        if (self.cameraStill.bounds.size.width > self.cameraStill.image?.size.width && self.cameraStill.bounds.size.height > self.cameraStill.image?.size.height) {
            self.cameraStill.contentMode = .ScaleAspectFill;
        }
        
        self.okayButton.alpha = 0.0

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
    @IBAction func goBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func okayUpload(sender: AnyObject) {
        if let image = self.cameraStill.image {
            IJProgressView.shared.showProgressView(view)
            
            let stillSize = CGSize(width: self.cameraStill.bounds.width * 2, height: self.cameraStill.bounds.height * 2)
            
            Enchant(url: self.enchantUrl!).uploadImage(image, size: stillSize, completed: { () -> Void in
                println("")
        
                IJProgressView.shared.hideProgressView()
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    
    @IBAction func captureFrame(sender: AnyObject) {
        if self.status == .Preview {
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.cameraPreview.alpha = 0.0;
                
                self.backButton.alpha = 0.0
            })
            
            self.camera?.captureStillImage({ (image) -> Void in
                if image != nil {
                    self.cameraStill.image = image;
                    
                    UIView.animateWithDuration(0.225, animations: { () -> Void in
                        self.cameraStill.alpha = 1.0;
                        self.okayButton.alpha = 1.0;
                    })
                    self.status = .Still
                } else {
                    self.status = .Error
                }
                
                self.cameraCapture.setTitle("Reset", forState: UIControlState.Normal)
            })
        } else if self.status == .Still || self.status == .Error {
            UIView.animateWithDuration(0.225, animations: { () -> Void in
                self.cameraPreview.alpha = 1.0;
                self.backButton.alpha = 1.0;
                
                self.cameraStill.alpha = 0.0;
                self.okayButton.alpha = 0.0
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}


