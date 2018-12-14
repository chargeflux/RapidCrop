//
//  CroppingView.swift
//  RapidCrop
//
//  Created by chargeflux on 12/13/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import Cocoa

class CroppingView: NSView {
    
    var startingPoint: CGPoint!
    
    var endingPoint: CGPoint!
    
    var cropShapeLayer: CAShapeLayer!
    
    var cropOverlayLayer: CALayer!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect);
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Crop NSImage to input CGRect `cropRect`
    /// - Parameters:
    ///     - inputImage: The input NSImage
    ///     - cropRect: The region to be cropped
    ///     - displayWidth: The width of image as displayed
    ///     - displayHeight: the height of the image as displayed
    func cropImage(_ inputImage: NSImage, cropRect: CGRect, displayWidth: CGFloat, displayHeight: CGFloat) -> NSImage?
    // Cropping function courtesy of Apple: https://developer.apple.com/documentation/coregraphics/cgimage/1454683-cropping
    {
        let imageViewScale = max(inputImage.size.width / displayWidth,
                                 inputImage.size.height / displayHeight)
        
        // Scale cropRect to handle images larger than shown-on-screen size (Apple)
        let scaledCropRect = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)
        
        // Perform cropping in Core Graphics (Apple)
        guard let croppedImageRef: CGImage = inputImage.cgImage(forProposedRect: nil, context: nil, hints: nil)?.cropping(to: scaledCropRect)
            else {
                return nil
        }
        
        // Return image to NSImage (Apple)
        let croppedImage: NSImage = NSImage(cgImage: croppedImageRef, size: scaledCropRect.size)
        return croppedImage
    }
    
    override func mouseDown(with event: NSEvent) {
        startingPoint = event.locationInWindow
        
        if cropOverlayLayer == nil {
            cropOverlayLayer = CALayer()
            cropOverlayLayer.opacity = 0.6
            cropOverlayLayer.backgroundColor = NSColor.black.cgColor
            cropOverlayLayer.frame = self.frame
            self.layer?.addSublayer(cropOverlayLayer)
        }
        
        cropShapeLayer = CAShapeLayer()

        cropShapeLayer.lineWidth = 2.0
        cropShapeLayer.fillColor = nil
        
        cropShapeLayer.strokeColor = NSColor.black.cgColor
        
        self.layer?.addSublayer(cropShapeLayer)
    }
    
    override func mouseDragged(with event: NSEvent) {

        let endPoint: NSPoint = event.locationInWindow

        let path = CGMutablePath()
        
        path.move(to: self.startingPoint)
        path.addLine(to: NSPoint(x: self.startingPoint.x, y: endPoint.y))
        path.addLine(to: endPoint)
        path.addLine(to: NSPoint(x:endPoint.x,y:self.startingPoint.y))
        
        path.closeSubpath()
        
        cropShapeLayer.path = path
    }
}
