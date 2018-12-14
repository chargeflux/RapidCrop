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
    
    var titlebarOffset: CGFloat!
    
    var imageScaling: CGFloat!
    
    @IBOutlet var mainImageView: MainImageView!

    var croppingView: CroppingView!
    
    var croppingViewExists: Bool = false
    
    var croppedImages: [NSImage] = []
    
    var fileImageURL: URL!

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
        croppingView = CroppingView.init(frame: mainImageView.bounds)
        self.view.addSubview(croppingView!)
        croppingViewExists = true
        self.fileImageURL = mainImageView.fileImageURL
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainImageView.delegate = self
    }
    
    override func viewDidAppear() {
        defaultWindowFrame = self.view.window?.frame
        defaultImageViewBounds = mainImageView.bounds
    }
    
    override func mouseUp(with event: NSEvent) {
        croppingView.endingPoint = self.view.convert(event.locationInWindow,from: croppingView)
        let mainImageViewHeight: CGFloat = mainImageView.image!.size.height
        var mainImageStartingPoint = croppingView.startingPoint * imageScaling
        mainImageStartingPoint.y = mainImageViewHeight - mainImageStartingPoint.y
        var mainImageEndingPoint =  croppingView.endingPoint * imageScaling
        mainImageEndingPoint.y = mainImageViewHeight - mainImageEndingPoint.y
        croppedImages.append(croppingView.cropImage(mainImageView.image!, cropRect: CGRect(x: mainImageStartingPoint.x, y: mainImageStartingPoint.y, width: mainImageEndingPoint.x - mainImageStartingPoint.x, height: mainImageEndingPoint.y - mainImageStartingPoint.y), displayWidth: mainImageView.bounds.width, displayHeight: mainImageView.bounds.height)!)
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
