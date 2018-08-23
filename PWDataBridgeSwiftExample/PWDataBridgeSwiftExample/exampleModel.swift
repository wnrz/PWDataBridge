//
//  exampleModel.swift
//  PWDataBridgeSwiftExample
//
//  Created by 王宁 on 2018/8/23.
//  Copyright © 2018年 王宁. All rights reserved.
//

import UIKit
import PWDataBridge.PWBaseDataBridge

class exampleModel: PWBaseDataBridge {

    @objc dynamic var string: NSString! = ""
    @objc dynamic var num: NSNumber! = NSNumber.init(value: 0)
    
    deinit {
        string = nil
    }
    
    override init() {
       
    }
}
