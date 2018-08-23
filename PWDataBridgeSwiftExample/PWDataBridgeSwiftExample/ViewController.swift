//
//  ViewController.swift
//  PWDataBridgeSwiftExample
//
//  Created by 王宁 on 2018/8/23.
//  Copyright © 2018年 王宁. All rights reserved.
//

import UIKit
import PWDataBridge

class ViewController: UIViewController {
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    var model: exampleModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

private extension ViewController {
    
    
    @IBAction func button1Pressed(sender: UIButton) {
        if model == nil {
            model = exampleModel()
        }
        model.addObserver(self, forKeyPath: "string", correction: { (value : Any?, result: AutoreleasingUnsafeMutablePointer<AnyObject?>?) in
            NSLog("string block before change is %@", value as! CVarArg)
            result?.pointee = NSString.init(format: "%@_changed_before_block", value as! CVarArg)
        }) { (value : Any?) in
            NSLog("string block value is : %@" , value as! CVarArg);
        }
        model.addObserver(self, forKeyPath: "string", correction: { (value : Any?, result: AutoreleasingUnsafeMutablePointer<AnyObject?>?) in
            NSLog("string block before change is %@", value as! CVarArg)
            result?.pointee = NSString.init(format: "%@_changed_before_action", value as! CVarArg)
        }, action:#selector(showStringData(value:)))
        
        model.addObserver(self, forKeyPath: "num", correction: { (value : Any?, result: AutoreleasingUnsafeMutablePointer<AnyObject?>?) in
            NSLog("num block before change is %@", value as! CVarArg)
            result?.pointee = NSString.init(format: "%@_changed_before_block", value as! CVarArg)
        }) { (value : Any?) in
            NSLog("num block value is : %@" , value as! CVarArg);
        }
        model.addObserver(self, forKeyPath: "num", correction: { (value : Any?, result: AutoreleasingUnsafeMutablePointer<AnyObject?>?) in
            NSLog("num block before change is %@", value as! CVarArg)
            result?.pointee = NSString.init(format: "%@_changed_before_action", value as! CVarArg)
        }, action:#selector(showNumData(value:)))
    }
    
    @IBAction func button2Pressed(sender: UIButton) {
        if model != nil {
            let h: NSInteger = NSInteger(arc4random() % 100);
            model.string = NSString.init(format: "string_%d", h)
        }
    }
    
    @IBAction func button3Pressed(sender: UIButton) {
        if model != nil {
            let i: NSInteger = NSInteger(model.num.intValue + 1);
            model.num = NSNumber.init(value: i)
        }
    }
    
    @IBAction func button4Pressed(sender: UIButton) {
        if model != nil {
            model.removeAllBridge()
            model = nil;
        }
    }
    
    @objc private func showStringData(value : Any?){
        NSLog("string action value is : %@", value as! CVarArg)
    }
    
    @objc private func showNumData(value : Any?){
        NSLog("string action value is : %@", value as! CVarArg)
    }
}
