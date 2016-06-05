//
//  APLViewController.swift
//  Touches
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/2/8.
//
//
/*
     File: APLViewController.h
     File: APLViewController.m
 Abstract: The main view controller for this application. The gesture recognizers for the view's pieces are set up in the storyboard.
  Version: 2.0

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2013 Apple Inc. All Rights Reserved.

 */

import UIKit
import QuartzCore

@objc(APLViewController)
class APLViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // Views the user can move.
    @IBOutlet private weak var firstPieceView: UIImageView!
    @IBOutlet private weak var secondPieceView: UIImageView!
    @IBOutlet private weak var thirdPieceView: UIImageView!
    
    private weak var pieceForReset: UIView?
    
    
    //MARK: - Utility methods
    
    /**
    Scale and rotation transforms are applied relative to the layer's anchor point this method moves a gesture recognizer's view's anchor point between the user's fingers.
    */
    private func adjustAnchorPointForGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .Began {
            let piece = gestureRecognizer.view!
            let locationInView = gestureRecognizer.locationInView(piece)
            let locationInSuperview = gestureRecognizer.locationInView(piece.superview)
            
            piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height)
            piece.center = locationInSuperview
        }
    }
    
    
    /**
    Display a menu with a single item to allow the piece's transform to be reset.
    */
    @IBAction private func showResetMenu(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .Began {
            
            self.becomeFirstResponder()
            self.pieceForReset = gestureRecognizer.view
            
            /*
            Set up the reset menu.
            */
            let menuItemTitle = NSLocalizedString("Reset", comment: "Reset menu item title")
            let resetMenuItem = UIMenuItem(title: menuItemTitle, action: #selector(APLViewController.resetPiece(_:)))
            
            let menuController = UIMenuController.sharedMenuController()
            menuController.menuItems = [resetMenuItem]
            
            let location = gestureRecognizer.locationInView(gestureRecognizer.view)
            let menuLocation = CGRectMake(location.x, location.y, 0, 0)
            menuController.setTargetRect(menuLocation, inView: gestureRecognizer.view!)
            
            menuController.setMenuVisible(true, animated: true)
        }
    }
    
    
    /**
    Animate back to the default anchor point and transform.
    */
    func resetPiece(controller: UIMenuController) {
        let pieceForReset = self.pieceForReset!
        
        let centerPoint = CGPointMake(CGRectGetMidX(pieceForReset.bounds), CGRectGetMidY(pieceForReset.bounds))
        let locationInSuperview = pieceForReset.convertPoint(centerPoint, toView: pieceForReset.superview)
        
        pieceForReset.layer.anchorPoint = CGPointMake(0.5, 0.5)
        pieceForReset.center = locationInSuperview
        
        UIView.beginAnimations(nil, context: nil)
        pieceForReset.transform = CGAffineTransformIdentity
        UIView.commitAnimations()
    }
    
    
    // UIMenuController requires that we can become first responder or it won't display
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    
    //MARK: - Touch handling
    
    /**
    Shift the piece's center by the pan amount.
    Reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position.
    */
    @IBAction private func panPiece(gestureRecognizer: UIPanGestureRecognizer) {
        let piece = gestureRecognizer.view!
        
        self.adjustAnchorPointForGestureRecognizer(gestureRecognizer)
        
        if gestureRecognizer.state == .Began || gestureRecognizer.state == .Changed {
            let translation = gestureRecognizer.translationInView(piece.superview!)
            
            piece.center = CGPointMake(piece.center.x + translation.x, piece.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPointZero, inView: piece.superview)
        }
    }
    
    
    /**
    Rotate the piece by the current rotation.
    Reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current rotation.
    */
    @IBAction private func rotatePiece(gestureRecognizer: UIRotationGestureRecognizer) {
        self.adjustAnchorPointForGestureRecognizer(gestureRecognizer)
        
        if gestureRecognizer.state == .Began || gestureRecognizer.state == .Changed {
            gestureRecognizer.view!.transform = CGAffineTransformRotate(gestureRecognizer.view!.transform, gestureRecognizer.rotation)
            gestureRecognizer.rotation = 0
        }
    }
    
    
    /**
    Scale the piece by the current scale.
    Reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current scale.
    */
    @IBAction private func scalePiece(gestureRecognizer: UIPinchGestureRecognizer) {
        self.adjustAnchorPointForGestureRecognizer(gestureRecognizer)
        
        if gestureRecognizer.state == .Began || gestureRecognizer.state == .Changed {
            gestureRecognizer.view!.transform = CGAffineTransformScale(gestureRecognizer.view!.transform, gestureRecognizer.scale, gestureRecognizer.scale)
            gestureRecognizer.scale = 1
        }
    }
    
    
    /**
    Ensure that the pinch, pan and rotate gesture recognizers on a particular view can all recognize simultaneously.
    Prevent other gesture recognizers from recognizing simultaneously.
    */
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // If the gesture recognizers's view isn't one of our pieces, don't allow simultaneous recognition.
        if gestureRecognizer.view !== self.firstPieceView && gestureRecognizer.view !== self.secondPieceView && gestureRecognizer.view != self.thirdPieceView {
            return false
        }
        
        // If the gesture recognizers are on different views, don't allow simultaneous recognition.
        if gestureRecognizer.view !== otherGestureRecognizer {
            return false
        }
        
        // If either of the gesture recognizers is the long press, don't allow simultaneous recognition.
        if gestureRecognizer is UILongPressGestureRecognizer || otherGestureRecognizer is UILongPressGestureRecognizer {
            return false
        }
        
        return true
    }
    
    
}