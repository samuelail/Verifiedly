//
//  ViewController.swift
//  Verifiedly
//
//  Created by Samuel Ailemen on 06/21/2021.
//  Copyright (c) 2021 Samuel Ailemen. All rights reserved.
//

import UIKit
import Verifiedly


let verifiedly = Verifiedly()

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verifiedly.verifiedly_key = "1234"
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func viewDidAppear(_ animated: Bool) {
 
    }
    
    @IBAction func beginVerification(_ sender: Any) {
        
        let vc =  verifiedly.initializeKYC()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

