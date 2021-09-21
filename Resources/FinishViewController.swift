//
//  FinishViewController.swift
//  Verifiedly
//
//  Created by Samuel Ailemen on 7/27/21.
//

import UIKit
import Lottie

class FinishViewController: UIViewController {

    private var animationView: AnimationView?
    @IBOutlet weak var backView: UIView!
    
    var session:String = ""
    var request_id:String = ""
    var verifiedly = Verifiedly()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "Verifiedly-4774-done", ofType: "json") else {return}
        animationView = .init(filePath: path)
        
        animationView!.frame = backView.bounds
        
    
        
        animationView!.contentMode = .scaleAspectFit
        
       
        
        animationView!.loopMode = .loop
        
       
        
        animationView!.animationSpeed = 0.5
        
        backView.addSubview(animationView!)
        
       
        
        animationView!.play()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

    }
    

    @IBAction func headHome(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion:{
            let itemDict = ["isExit": "no", "requestID": self.request_id] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "verifiedlyDidTriggerResponse"), object: nil, userInfo: itemDict)
        })
       // self.dismiss(animated: true, completion: nil)
    }
    

}
