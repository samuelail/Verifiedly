//
//  PersonalViewController.swift
//  Verifiedly
//
//  Created by Samuel Ailemen on 6/21/21.
//

import UIKit

class PersonalViewController: UIViewController {

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view1.layer.borderWidth = 0.5
        view1.layer.borderColor = UIColor.lightGray.cgColor
        
        view2.layer.borderWidth = 0.5
        view2.layer.borderColor = UIColor.lightGray.cgColor
        
        view3.layer.borderWidth = 0.5
        view3.layer.borderColor = UIColor.lightGray.cgColor

        // Do any additional setup after loading the view.
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
