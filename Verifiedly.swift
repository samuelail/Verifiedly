//
//  Verifiedly.swift
//  Verifiedly
//
//  Created by Samuel Ailemen on 6/21/21.
//

import Foundation

protocol VerifiedlyControllerDelegate: AnyObject {
  
  /** Called whenever a CreditCardScannerViewControllerDelegate instance validates a credit card number from a visual scan. */
  func kycCompleted(result: String, requestID: String, status: String)
}

public class Verifiedly {
    
    public var verifiedly_key = ""
  public  init () {
        
    }
    
    public func initializeKYC() -> UIViewController {
        var vc = UIViewController()
        if verifiedly_key.isEmpty {
            print("You need to provide an api key before you initialize verifiedly")
        } else {
            let verifiedly = UIStoryboard.init(name: "Verifiedly", bundle: Bundle(for: type(of: self)))
            let initialVC = verifiedly.instantiateViewController(withIdentifier: "initialVC") as! InitialViewController
            vc = initialVC
        }
        
        return vc
    }
}
