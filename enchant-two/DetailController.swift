//
//  DetailViewController.swift
//  Enchant
//
//  Created by Filip Hájek on 6.12.2014.
//  Copyright (c) 2014 Enchant. All rights reserved.
//

import UIKit

class DetailController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let recognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
//        recognizer.delegate = self
//        view.addGestureRecognizer(recognizer)
//        
//        self.photoImage.contentMode = .Center;
//        if (photoImage.bounds.size.width > self.photoImage.image?.size.width && photoImage.bounds.size.height > self.photoImage.image?.size.height) {
//            photoImage.contentMode = .ScaleAspectFit;
//        }
//        
//        self.titleLabel.text = self.Enchantphoto!.filename
//        self.photoImage.image = self.Enchantphoto!.image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
