//
//  ViewController.swift
//  RapidCrop
//
//  Created by chargeflux on 12/12/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import Cocoa

class RapidCropViewController: NSViewController {
    
    var defaultWindowFrame: NSRect!
    
    var defaultImageViewBounds: NSRect!
    
    @IBOutlet var mainImageView: MainImageView!

    var croppingView: CroppingView?
    
    var croppingViewExists: Bool = false

    @IBAction func mainImageViewSet(_ sender: Any) {
        if croppingViewExists {
            croppingView!.removeFromSuperview()
            croppingViewExists = false
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        if !croppingViewExists {
            croppingView = CroppingView.init(frame: mainImageView.bounds)
            self.view.addSubview(croppingView!)
            croppingViewExists = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainImageView.delegate = self
    }
    
    override func viewDidAppear() {
        defaultWindowFrame = self.view.window?.frame
        defaultImageViewBounds = mainImageView.bounds
    }
}

extension CGSize {
    static func >(lhs: CGSize, rhs: CGSize) -> Bool {
        if lhs.width > rhs.width && lhs.height > rhs.height {
            return true
        }
        return false
    }
}

extension RapidCropViewController: MainImageViewDelegate {
    
    func setWindowSize(aspectRatio: CGFloat,size: NSSize) {
        let titlebarOffset = defaultWindowFrame.size.height-defaultImageViewBounds.size.height
        if aspectRatio != (defaultWindowFrame.size.width/(defaultWindowFrame.size.height-titlebarOffset)) {
            if size > defaultWindowFrame.size {
                self.view.window?.setFrame(NSRect(x: defaultWindowFrame.minX, y: defaultWindowFrame.minY, width:defaultWindowFrame.size.width, height: (defaultWindowFrame.width/aspectRatio)+titlebarOffset), display: true)
            }
            else {
                self.view.window?.setFrame(NSRect(x: defaultWindowFrame.minX, y: defaultWindowFrame.minY, width: size.width, height: size.height+titlebarOffset), display: true)
            }
        }
        else {
            if self.view.window!.frame != defaultWindowFrame {
                self.view.window!.setFrame(defaultWindowFrame, display: true)
            }
        }
    }
    
}
