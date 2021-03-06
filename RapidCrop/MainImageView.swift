//
//  MainImageView.swift
//  RapidCrop
//
//  Created by chargeflux on 12/12/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import Cocoa

protocol MainImageViewDelegate {
    func setWindowSize(aspectRatio: CGFloat, size: NSSize)
}

class MainImageView: NSImageView {
    
    var fileImageURL: URL?
    
    var delegate: MainImageViewDelegate?
    
    // Dragging a file (no distinction of image) from Finder has a PasteboardType of "public.file-url"
    // Can be determined via `draggingPasteboard.availableType(from: draggingPasteboard.types!)`
    let acceptedDraggingPasteboardTypes: [NSPasteboard.PasteboardType] = [NSPasteboard.PasteboardType.fileURL]

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        registerForDraggedTypes(acceptedDraggingPasteboardTypes)

    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        /// Parse input and accept if it is an image
        
        let draggingPasteboard: NSPasteboard = sender.draggingPasteboard
        
        let sourceDragMask: NSDragOperation = sender.draggingSourceOperationMask
        
        /// if input being dragged is a file and NSImage can initialize from that input
        if acceptedDraggingPasteboardTypes.contains(draggingPasteboard.availableType(from: draggingPasteboard.types!)!) && NSImage.canInit(with: draggingPasteboard){
            if sourceDragMask == NSDragOperation.generic {
                return NSDragOperation.generic
            }
            return NSDragOperation.copy
        }
        return []
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        /// if input is accepted, get the file URL of input, rescale window frame to the image's aspect ratio
        /// and set MainImageView to the image
        
        fileImageURL = URL(string: (sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType.fileURL) as! String))
    
        let image = NSImage.init(pasteboard: sender.draggingPasteboard)
    
        delegate?.setWindowSize(aspectRatio: getAspectRatio(image: image!),size: image!.size)
    
        self.image = image
        
        return true
    }
    
    func getAspectRatio(image: NSImage) -> CGFloat {
        return image.size.width/image.size.height
    }
}
