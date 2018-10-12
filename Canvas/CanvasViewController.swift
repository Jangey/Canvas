//
//  ViewController.swift
//  Canvas
//
//  Created by Jangey Lu on 10/8/18.
//  Copyright © 2018 Jangey Lu. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController {

    // element for trayPan
    @IBOutlet weak var trayView: UIView!
    var trayOriginalCenter: CGPoint!
    
    // element for faces
    var newlyCreatedFace: UIImageView!
    var newlyCreatedFaceOriginalCenter: CGPoint!
    
    // properties for tray up & tray down
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    
    // Tray arrow
    @IBOutlet weak var arrow: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        trayDownOffset = 200
        trayUp = trayView.center // The initial position of the tray
        trayDown = CGPoint(x: trayView.center.x ,y: trayView.center.y + trayDownOffset) // The position of the tray transposed down
        
    }

    // Pan for Tray
    @IBAction func didPanTray(_ sender: UIPanGestureRecognizer) {
        //let location = sender.location(in: view)
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == .began {
            trayOriginalCenter = trayView.center
        } else if sender.state == .changed {
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
        } else if sender.state == .ended {
            if velocity.y > 0 {
                // trayView going down when push down
                UIView.animate(withDuration:0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                               animations: { () -> Void in
                                self.trayView.center = self.trayDown
                                self.arrow.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                }, completion: nil)
                
            } else {
                // trayView going up when pull up
                UIView.animate(withDuration:0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                               animations: { () -> Void in
                                self.trayView.center = self.trayUp
                                self.arrow.transform = CGAffineTransform(rotationAngle: CGFloat(2*Double.pi))
                }, completion: nil)
                //arrow.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            }
        }
    }
    
    // Pan for face
    @IBAction func didPanFace(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        if sender.state == .began {
            
            //imageView now refers to the face that you panned on.
            let imageView = sender.view as! UIImageView
            
            // Create a new image view that has the same image as the one you're currently panning.
            newlyCreatedFace = UIImageView(image: imageView.image)
            
            //Add the new face to the main view.
            view.addSubview(newlyCreatedFace)
            
            //Initialize the position of the new face.
            newlyCreatedFace.center = imageView.center
            
            //Since the original face is in the tray, but the new face is in the main view, you have to offset the coordinates.
            newlyCreatedFace.center.y += trayView.frame.origin.y
            
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
            
            // add a UIPanGestureRecognizer to the newly created face
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanOriginalFace(sender:)))
            newlyCreatedFace.isUserInteractionEnabled = true
            newlyCreatedFace.addGestureRecognizer(panGestureRecognizer)
            
            // add a UIPinchGestreRecognizer to the newly created face
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinchOriginalFace(sender:)))
            newlyCreatedFace.addGestureRecognizer(pinchGestureRecognizer)
            
            // add a UIRotationGestreRecognizer to the newly created face
            let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(didRotationOriginalFace(sender:)))
            newlyCreatedFace.addGestureRecognizer(rotationGestureRecognizer)

        } else if sender.state == .changed {
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
            
            // the animate when moving the face
            UIView.animate(withDuration: 0.2) {
                self.newlyCreatedFace.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            }
            
        } else if sender.state == .ended {
            // ending Spring animation
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: { () -> Void in
                self.newlyCreatedFace.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        }
    }
    
    @objc func didPanOriginalFace(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        if sender.state == .began {
            newlyCreatedFace = sender.view as? UIImageView // to get the face that we panned on.
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center // so we can offset by translation later.
        } else if sender.state == .changed {
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
        } else if sender.state == .ended {
        }
    }
    
    @objc func didPinchOriginalFace(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        let imageView = sender.view as! UIImageView
        imageView.transform = imageView.transform.scaledBy(x: scale, y: scale)
        sender.scale = 1
    }
    
    @objc func didRotationOriginalFace(sender: UIRotationGestureRecognizer) {
        let rotation = sender.rotation
        let imageView = sender.view as! UIImageView
        imageView.transform = imageView.transform.rotated(by: rotation)
        sender.rotation = 0
    }
}

