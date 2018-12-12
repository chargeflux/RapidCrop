//
//  ViewController.swift
//  RapidCrop
//
//  Created by chargeflux on 12/12/18.
//  Copyright © 2018 chargeflux. All rights reserved.
//

import Cocoa
class RapidCropViewController: NSViewController {
    
    weak var currentImage: NSImage?
    
    @IBOutlet var mainImageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
