//
//  MainImageView.swift
//  RapidCrop
//
//  Created by chargeflux on 12/12/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import Cocoa

class MainImageView: NSImageView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    let acceptedDraggingPasteboardTypes: [NSPasteboard.PasteboardType] = [NSPasteboard.PasteboardType.fileURL]
    
    let acceptedDraggingFileTypes: [String] = ["jpg","jpeg","tiff","png"]
    // TODO: Implement file extension check
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        registerForDraggedTypes(acceptedDraggingPasteboardTypes)
        
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let draggingPasteboard: NSPasteboard = sender.draggingPasteboard
        
        let sourceDragMask: NSDragOperation = sender.draggingSourceOperationMask
        
        
        if !(Set(draggingPasteboard.types!).intersection(Set(acceptedDraggingPasteboardTypes)).isEmpty) {

            if sourceDragMask == NSDragOperation.generic {
                return NSDragOperation.generic;
            }
            return NSDragOperation.copy
        }
        return []
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let dragImageURL: String = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType.fileURL) as! String
        self.image = NSImage(byReferencing: URL(string: dragImageURL)!)
        return true
    }
    
}
