//
//  ViewController.swift
//  RapidCrop
//
//  Created by chargeflux on 12/12/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

class RapidCropViewController: NSViewController {
    
    var defaultWindowFrame: NSRect!
    
    var defaultImageViewBounds: NSRect!
    
    var titlebarOffset: CGFloat!
    
    var imageScaling: CGFloat!
    
    @IBOutlet var mainImageView: MainImageView!

    var croppingView: CroppingView!
    
    var croppingViewExists: Bool = false
    
    var croppedImages: [NSImage] = []
    
    var fileImageURL: URL!
    
    var keyboardShortcutMonitor: Any?

    @IBAction func mainImageViewSet(_ sender: Any) {
        imageScaling = mainImageView.image!.size.width/mainImageView.bounds.size.width
        if croppedImages != [] {
            saveImage()
        }
        croppedImages.removeAll()
        if croppingViewExists {
            croppingView!.removeFromSuperview()
            croppingViewExists = false
        }
        initializeCroppingView()
        self.fileImageURL = mainImageView.fileImageURL
    }
    
    func initializeCroppingView() {
        croppingView = CroppingView.init(frame: mainImageView.bounds)
        self.view.addSubview(croppingView!)
        croppingViewExists = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainImageView.delegate = self
        
        // Start monitor for keyboard shortcuts via keyDown NSEvents
        startKeyboardShortcutMonitor()
    }
    
    override func viewDidAppear() {
        defaultWindowFrame = self.view.window?.frame
        defaultImageViewBounds = mainImageView.bounds
    }
    
    func startKeyboardShortcutMonitor() {
        /// Initializes monitor for keyboard shortcuts, i.e., when user presses a key
        self.keyboardShortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: keyboardShortcut)
    }
    
    func keyboardShortcut(_ event: NSEvent) -> NSEvent? {
        // If particular shortcut is pressed, certain functions are executed and returns the
        // the event as `nil` to prevent triggering the "Basso"/default alert sound because the
        // system won't recognize the key press as a valid input/shortcut. Otherwise the event
        // is returned as is to the system input manager to be processed.
        switch Int(event.keyCode) {
        /// Check if Escape key is pressed: remove last selection
        case kVK_Escape:
            if !event.isARepeat {
                if croppedImages != [] {
                    croppedImages.removeLast()
                    croppingView.layer?.sublayers!.removeLast()
                }
            }
            return nil
        /// Check if "S" key is pressed: Save cropped regions as individual files
        case kVK_ANSI_S:
            if !event.isARepeat && croppedImages != [] {
                saveImage()
                croppedImages.removeAll()
                if croppingViewExists {
                    croppingView.removeFromSuperview()
                    croppingViewExists = false
                }
                mainImageView.image = nil
            }
            return nil
        default:
            return event
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if croppingView != nil {
        croppingView.endingPoint = event.locationInWindow
        let mainImageViewHeight: CGFloat = mainImageView.bounds.size.height
        
        let mainImageStartingPoint = croppingView.startingPoint!
        let mainImageStartingPointModifiedY = mainImageViewHeight - mainImageStartingPoint.y // NSImage y-coordinate ≠ view coordinates
        let mainImageEndingPoint =  croppingView.endingPoint!
        
        croppedImages.append(croppingView.cropImage(mainImageView.image!, cropRect: CGRect(x: mainImageStartingPoint.x, y: mainImageStartingPointModifiedY, width: mainImageEndingPoint.x - mainImageStartingPoint.x, height: mainImageStartingPoint.y - mainImageEndingPoint.y), displayWidth: mainImageView.bounds.width, displayHeight: mainImageView.bounds.height)!)
        }
    }
    
    func saveImage() {
        let fileManager = FileManager()
        let downloadDirectory = try! fileManager.url(for: .downloadsDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
        let savePath = downloadDirectory.appendingPathComponent("Output", isDirectory: true)
        let fileName = String(fileImageURL.lastPathComponent.split(separator: ".")[0])
        for (index, image) in croppedImages.enumerated() {
            var tempSavePath = savePath
            tempSavePath.appendPathComponent(fileName, isDirectory: true)
            try! fileManager.createDirectory(at: tempSavePath, withIntermediateDirectories: true, attributes: nil)
            tempSavePath.appendPathComponent(String(index), isDirectory: false)
            tempSavePath.appendPathExtension("png")
            
            let imageBitmapRep = NSBitmapImageRep(data: image.tiffRepresentation!)
            let imagePNG = imageBitmapRep?.representation(using: .png, properties: [.compressionFactor: 1.0])
            try! imagePNG?.write(to: tempSavePath)
        }
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

extension CGPoint {
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        if rhs > 1 {
            return CGPoint(x:lhs.x * rhs, y:lhs.y * rhs)
        }
        if rhs < 1 {
            return CGPoint(x:lhs.x/rhs, y:lhs.y/rhs)
        }
        return lhs
    }
}

extension RapidCropViewController: MainImageViewDelegate {
    
    func setWindowSize(aspectRatio: CGFloat,size: NSSize) {
        titlebarOffset = defaultWindowFrame.size.height-defaultImageViewBounds.size.height
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
