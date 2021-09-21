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
//let resultController = verifiedly.resultController

class ViewController: UIViewController {

 
    @IBOutlet weak var tokenTxt: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.tokenTxt.text)
        
        verifiedly.app_name = "Padle"
        
        //VERY IMPORTANT
        verifiedly.awaitResult()
        DispatchQueue.main.async {
            
            verifiedly.onComplete = { (result) in
                print(result)
            
            }
            
            verifiedly.onExit = { (result) in
                print(result)
            }
        }
       
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func beginVerification(_ sender: Any) {
        verifiedly.session_id  = self.tokenTxt.text ?? ""
        let vc =  verifiedly.initializeKYC()
        self.present(vc, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


