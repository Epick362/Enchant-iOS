/*
* QRCodeReader.swift
*
* Copyright 2014-present Yannick Loriot.
* http://yannickloriot.com
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*
*/

import UIKit
import Alamofire
import AVFoundation
import SwiftyJSON

class ReaderController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private var cameraView: ReaderUIView = ReaderUIView()
    private var switchCameraButton: CameraUIButton?
    
    private var defaultDevice: AVCaptureDevice? = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    private var frontDevice: AVCaptureDevice?   = {
        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
            if let _device = device as? AVCaptureDevice {
                if _device.position == AVCaptureDevicePosition.Front {
                    return _device
                }
            }
        }
        
        return nil
        }()
    private lazy var defaultDeviceInput: AVCaptureDeviceInput? = {
        if let _defaultDevice = self.defaultDevice {
            return AVCaptureDeviceInput(device: _defaultDevice, error: nil)
        }
        
        return nil
        }()
    private lazy var frontDeviceInput: AVCaptureDeviceInput?  = {
        if let _frontDevice = self.frontDevice {
            return AVCaptureDeviceInput(device: _frontDevice, error: nil)
        }
        
        return nil
        }()
    private var metadataOutput: AVCaptureMetadataOutput       = AVCaptureMetadataOutput()
    private var session: AVCaptureSession                     = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = { return AVCaptureVideoPreviewLayer(session: self.session) }()
    
    var completionBlock: ((String?) -> ())?
    
    var scannedString: String?
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupUIComponents()
        configureDefaultComponents()
        setupAutoLayoutConstraints()
        
        view.backgroundColor = UIColor.blackColor()
        
        cameraView.layer.insertSublayer(previewLayer, atIndex: 0)
        
        startScanning()
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        startScanning()
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopScanning()
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        previewLayer.frame = view.bounds
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "qrnotfound") {
            var cameraController: CameraController = segue.destinationViewController as CameraController
            
            cameraController.enchantUrl = self.scannedString
        }else if(segue.identifier == "qrfound"){
//            var EnchantController: EnchantController = segue.destinationViewController as EnchantController
//            
//            EnchantController.enchantUrl = self.scannedString
        }
    }
    
    // MARK: - Initializing the AV Components
    
    private func setupUIComponents() {
        cameraView.clipsToBounds = true
        cameraView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(cameraView)
        
        if let _frontDevice = frontDevice {
            let newSwitchCameraButton = CameraUIButton()
            newSwitchCameraButton.setTranslatesAutoresizingMaskIntoConstraints(false)
            newSwitchCameraButton.addTarget(self, action: "switchCameraAction:", forControlEvents: .TouchUpInside)
            view.addSubview(newSwitchCameraButton)
            
            switchCameraButton = newSwitchCameraButton
        }
        
    }
    
    private func setupAutoLayoutConstraints() {
        let views: [NSObject: AnyObject] = ["cameraView": cameraView]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[cameraView]|", options: .allZeros, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[cameraView]|", options: .allZeros, metrics: nil, views: views))
        
        if let _switchCameraButton = switchCameraButton {
            let switchViews: [NSObject: AnyObject] = ["switchCameraButton": _switchCameraButton]
            
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[switchCameraButton(50)]", options: .allZeros, metrics: nil, views: switchViews))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[switchCameraButton(70)]|", options: .allZeros, metrics: nil, views: switchViews))
        }
    }
    
    private func configureDefaultComponents() {
        session.addOutput(metadataOutput)
        
        if let _defaultDeviceInput = defaultDeviceInput {
            session.addInput(defaultDeviceInput)
        }
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        if let _availableMetadataObjectTypes = metadataOutput.availableMetadataObjectTypes as? [String] {
            if _availableMetadataObjectTypes.filter({ $0 == AVMetadataObjectTypeQRCode }).count > 0 {
                metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            }
        }
        previewLayer.videoGravity          = AVLayerVideoGravityResizeAspectFill
    }
    
    private func switchDeviceInput() {
        if let _frontDeviceInput = frontDeviceInput {
            session.beginConfiguration()
            
            if let _currentInput = session.inputs.first as? AVCaptureDeviceInput {
                session.removeInput(_currentInput)
                
                let newDeviceInput = (_currentInput.device.position == .Front) ? defaultDeviceInput : _frontDeviceInput
                session.addInput(newDeviceInput)
            }
            
            session.commitConfiguration()
        }
    }
    
    // MARK: - Controlling Reader
    
    private func startScanning() {
        if !session.running {
            session.startRunning()
        }
    }
    
    private func stopScanning() {
        if session.running {
            session.stopRunning()
        }
    }
    
    func switchCameraAction(button: CameraUIButton) {
        switchDeviceInput()
    }
    
    // MARK: - AVCaptureMetadataOutputObjects Delegate Methods
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        for current in metadataObjects {
            if let _readableCodeObject = current as? AVMetadataMachineReadableCodeObject {
                if _readableCodeObject.type == AVMetadataObjectTypeQRCode {
                    stopScanning()
                    
                    let scannedResult: String = _readableCodeObject.stringValue
                    
                    self.scannedString = scannedResult
                    
                    Alamofire.request(.GET, "http://enchant-app.com/api/v1/enchant", parameters: ["url": self.scannedString!])
                        .validate()
                        .responseJSON { (_, _, data, _) in
                            if data != nil {
                                let json: JSON = JSON(data!)
                                
                                if let url = json["url"].string {
                                    println("found")
                                    self.performSegueWithIdentifier("qrfound", sender: self)
                                }else{
                                    println("notfound")
                                    self.performSegueWithIdentifier("qrnotfound", sender: self)
                                }
                            }
                    }
                }
            }
        }
    }
}