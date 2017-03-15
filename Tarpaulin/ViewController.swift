//
//  ViewController.swift
//  Tarpaulin
//
//  Created by Jose Guerrero on 3/14/17.
//  Copyright © 2017 Jose Guerrero. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // UI elements
    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var downArrow: UIImageView!
    
    
    // Member Variables (Properties)
    private var trayCenterWhenOpen: CGPoint!
    private var trayCenterWhenClosed: CGPoint!
    private var trayOriginalCenter: CGPoint!
    private var trayIsOpen = false
    private var newlyCreatedFace: UIImageView!
    private var nCFOriginalCenter: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trayCenterWhenClosed = trayView.center
        trayCenterWhenOpen = CGPoint(x: trayView.center.x, y: trayView.center.y-173)
        downArrow.transform = CGAffineTransform(rotationAngle: 180*(CGFloat.pi/180))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // This handles the movement of trayView upon tapping
    @IBAction func onViewTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if trayIsOpen {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 20, options: [], animations: {
                    self.trayView.center = self.trayCenterWhenClosed
                    self.downArrow.transform = CGAffineTransform(rotationAngle: 180*(CGFloat.pi/180))
                }, completion: { (success: Bool) in
                    self.trayIsOpen = false
                })
            }
            else{
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 20, options: [], animations: {
                    self.trayView.center = self.trayCenterWhenOpen
                    self.downArrow.transform = CGAffineTransform(rotationAngle: 0)
                }, completion: { (success: Bool) in
                    self.trayIsOpen = true
                })
            }
            
            
        }
    }
    
    // This handles the panning of the trayView at the bottom of screen
    @IBAction func onViewPan(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: view)
        let translation = sender.translation(in: view)
        let viewYRange = trayCenterWhenClosed.y - trayCenterWhenOpen.y
        let rotationRange = 180*(CGFloat.pi/180) - 0
        
        if sender.state == UIGestureRecognizerState.began {
            NSLog("Gesture began at: %@", NSStringFromCGPoint(location))
            trayOriginalCenter = trayView.center
            
        } else if (sender.state == UIGestureRecognizerState.changed) {
            NSLog("Gesture changed at: %@", NSStringFromCGPoint(location))
            
            if (trayView.center.y < trayCenterWhenOpen.y) {
                trayView.center = CGPoint(x: trayOriginalCenter.x,y: trayView.center.y + translation.y/10)
            }
            else {
                trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayView.center.y+translation.y)
            }
            sender.setTranslation(CGPoint.zero, in: view)
            downArrow.transform = CGAffineTransform(rotationAngle: trayCenterWhenOpen.y/trayView.center.y < 1 ? (((trayView.center.y - trayCenterWhenOpen.y) * rotationRange) / viewYRange):0)
            
        } else if (sender.state == UIGestureRecognizerState.ended) {
            NSLog("Gesture ended at: %@", NSStringFromCGPoint(location))
            if sender.velocity(in: view).y > 0{
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 20, options: [], animations: {
                    self.trayView.center = self.trayCenterWhenClosed
                    
                    self.downArrow.transform = CGAffineTransform(rotationAngle: 180*(CGFloat.pi/180))
                }, completion: { (success: Bool) in
                    self.trayIsOpen = false
                })
            }
            else{
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 20, options: [], animations: {
                    self.trayView.center = self.trayCenterWhenOpen
                    self.downArrow.transform = CGAffineTransform(rotationAngle: 0)
                }, completion: { (success: Bool) in
                    self.trayIsOpen = true
                })
            }
            
            
        }
    }
    
    // This handles the creation and initial panning of new faces
    @IBAction func onImagePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: trayView)
        
        if sender.state == UIGestureRecognizerState.began {
            // Gesture recognizers know the view they are attached to
            let imageView = sender.view as! UIImageView
            
            newlyCreatedFace = UIImageView.init(image: imageView.image)
            newlyCreatedFace.contentMode = .scaleAspectFit
            newlyCreatedFace.frame.size = CGSize(width: 70, height: 70)
            
            newlyCreatedFace.isUserInteractionEnabled = true
            
            let facePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onNewFacePan(sender:)))
            let facePinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(onFacePinch(sender:)))
            let faceRotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(onFaceRotate(sender:)))
            let faceTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onFaceDoubleTap(sender:)))
            faceTapGestureRecognizer.numberOfTapsRequired = 2
            
            facePinchGestureRecognizer.delegate = self
            facePanGestureRecognizer.delegate = self
            faceRotateGestureRecognizer.delegate = self
            faceTapGestureRecognizer.delegate = self
            
            
            // Add Pan, Pinch, Rotate, and Tap Gesture recognizer to newlycreatedFace
            newlyCreatedFace.addGestureRecognizer(facePanGestureRecognizer)
            newlyCreatedFace.addGestureRecognizer(facePinchGestureRecognizer)
            newlyCreatedFace.addGestureRecognizer(faceRotateGestureRecognizer)
            newlyCreatedFace.addGestureRecognizer(faceTapGestureRecognizer)
            
            
            // Add the new face to the tray's parent view.
            self.view.addSubview(newlyCreatedFace)
            
            // Initialize the position of the new face.
            newlyCreatedFace.center = imageView.center;
            
            // Since the original face is in the tray, but the new face is in the
            // main view, you have to offset the coordinates
            let faceCenter = newlyCreatedFace.center
            newlyCreatedFace.center = CGPoint(x: faceCenter.x,
                                              y: faceCenter.y + trayView.frame.origin.y)
            nCFOriginalCenter = newlyCreatedFace.center
            
        }
        else if (sender.state == UIGestureRecognizerState.changed) {
            
            newlyCreatedFace.center = CGPoint(x: nCFOriginalCenter.x+translation.x, y: nCFOriginalCenter.y+translation.y)
            
        }
        else if (sender.state == UIGestureRecognizerState.ended) {
            if newlyCreatedFace.center.y > 369 {
                UIView.animate(withDuration: 0.2, animations: {
                    let faceCenter = (sender.view?.center)!
                    self.newlyCreatedFace.center = CGPoint(x: faceCenter.x, y: faceCenter.y + self.trayView.frame.origin.y)
                }, completion: { (success: Bool) in
                    if success {
                        self.newlyCreatedFace.removeFromSuperview()
                    }
                })
            }
            else{
                self.view.bringSubview(toFront: trayView)
            }
        }
    }
    
    // This handles the new face deletion functionality
    func onFaceDoubleTap(sender: UITapGestureRecognizer){
        sender.view?.removeFromSuperview()
    }
    
    // This handles the new face pinching functionality
    func onFacePinch(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        let imageView = sender.view as! UIImageView
        imageView.transform = imageView.transform.scaledBy(x: scale, y: scale)
        sender.scale = 1
    }
    
    // This handles the new face rotation functionality
    func onFaceRotate(sender: UIRotationGestureRecognizer){
        let rotation = sender.rotation
        let imageView = sender.view as! UIImageView
        imageView.transform = imageView.transform.rotated(by: rotation)
        sender.rotation = 0
    }
    
    // This handles the new face panning
    func onNewFacePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: trayView)
        
        if sender.state == UIGestureRecognizerState.began {
            nCFOriginalCenter = sender.view?.center
            UIView.animate(withDuration: 0.2, animations: {
                
                sender.view?.transform = (sender.view?.transform.scaledBy(x: 1.5, y: 1.5))!
            })
        }
        else if (sender.state == UIGestureRecognizerState.changed) {
            
            sender.view?.center = CGPoint(x: nCFOriginalCenter.x+translation.x, y: nCFOriginalCenter.y+translation.y)
            
        }
        else if (sender.state == UIGestureRecognizerState.ended) {
            UIView.animate(withDuration: 0.2, animations: {
                sender.view?.transform = (sender.view?.transform.scaledBy(x: 0.6666, y: 0.6666))!
            }, completion: { (success: Bool) in
                if success {
                    if (sender.view?.center.y)! > CGFloat(369) && self.trayIsOpen {
                        sender.view?.removeFromSuperview()
                    }
                }
            })
        }
        
    }
}

