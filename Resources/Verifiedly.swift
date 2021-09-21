//
//  Verifiedly.swift
//  Verifiedly
//
//  Created by Samuel Ailemen on 6/21/21.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit


public class Verifiedly{
    
    
    public var session_id = ""
    public var app_name:String = "[App name]"

   public var onComplete: ((_ result: String)->())?
   public var onExit: ((_ result: String)->())?

    
    //var resultController = InitialViewController()
  public  init () {

    }

    public func awaitResult(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.didExit(_:)), name: NSNotification.Name(rawValue: "verifiedlyDidTriggerResponse"), object: nil)
    }
    
    @objc func didExit(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
           // print(dict)
            guard let exit =  dict["isExit"] as? String else {return}
            if exit == "yes" {
                self.onExit?("User terminated KYC session")
            } else {
                guard let request_id =  dict["requestID"] as? String else {return}
                self.onComplete?(request_id)
            }

        }
       
        }
    
    public func initializeKYC() -> UIViewController {
        var vc = UIViewController()
        if session_id.isEmpty {
            print("You need to provide a valid session id before you initialize verifiedly")
        } else {
            let verifiedly = UIStoryboard.init(name: "Verifiedly", bundle: Bundle(for: type(of: self)))
            let initialVC = verifiedly.instantiateViewController(withIdentifier: "initialVC") as! InitialViewController
            initialVC.modalPresentationStyle = .fullScreen
            initialVC.modalTransitionStyle = .crossDissolve
            initialVC.session = self.session_id
            initialVC.app_name = self.app_name
            vc = initialVC
        }
        
        return vc
    }
    

}


