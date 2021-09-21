//
//  InitialViewController.swift
//  Verifiedly
//
//  Created by Samuel Ailemen on 6/21/21.
//

import UIKit
import ActiveLabel
import Alamofire
import SwiftyJSON
import RappleProgressHUD
import SwiftMessages
import SwiftPublicIP

protocol AlertPageViewDelegate {
    func nextStep(_ step: Int)
}

class InitialViewController: UIViewController {
    
    
    
    var session:String = ""
    var app_name = ""
    private var ipAddress:String = "-"
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var customerTxt: UILabel!
    @IBOutlet weak var termsTxt: ActiveLabel!
    @IBOutlet weak var requirement1: UILabel!
    @IBOutlet weak var dismissBtn: UIButton!
    
    @IBOutlet weak var requirement2: UILabel!
    @IBOutlet weak var requirement3: UILabel!
    @IBOutlet weak var requirement4: UILabel!
    var delegate: AlertPageViewDelegate?
    var verifiedly = Verifiedly()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissBtn.isHidden = false
        self.termsTxt.isHidden = true
        self.agreeBtn.isHidden = true
        self.cancelBtn.isHidden = true
        self.customerTxt.isHidden = true
        self.requirement1.isHidden = true
        self.requirement2.isHidden = true
        self.requirement3.isHidden = true
        self.requirement4.isHidden = true
        
        self.customerTxt.text = "\(app_name) uses Verifiedly to perform identity verification"
        
        //Get device's IP Address 
        SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { (string, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let string = string {
               // print(string) // Your IP address
                self.ipAddress = string
            }
        }
    
        
  //
        //Validate the session
       
        self.validateSession(session: session)

        // Do any additional setup after loading the view.
        //0957F9
        
        self.cancelBtn.layer.borderWidth = 0.5
        self.cancelBtn.layer.borderColor = hexStringToUIColor(hex: "0957F9").cgColor
        
        //Set active label
        let customType = ActiveType.custom(pattern: "\\sprivacy policy\\b")
        termsTxt.enabledTypes = [.url, customType]
        termsTxt.text = "By continuing this verification, you agree to Verifiedly's privacy policy agreement"
        termsTxt.customColor[customType] = hexStringToUIColor(hex: "0957F9")
        termsTxt.customSelectedColor[customType] = hexStringToUIColor(hex: "0957F9")
        termsTxt.handleCustomTap(for: customType) { element in
            if let url = URL(string: "https://verified.ly/privacy") {
                UIApplication.shared.open(url)
            }
        }
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
    }
    

    
    @IBAction func doAgree(_ sender: Any) {
        //Agree to terms
        RappleActivityIndicatorView.startAnimating()
        let parameters = ["session": session,
                          "ip": ipAddress]
        AF.request("https://api.verified.ly/v1/mobile/kyc/terms", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
           
            switch response.result {
            case .success:
            if response.response?.statusCode == 200 {
                RappleActivityIndicatorView.stopAnimation(completionIndicator: .success, completionLabel: "Success", completionTimeout: 1.0)
                let json = try? JSON(data: response.data!)
                guard let step = json!["current_step"].int else {return}
               
                if step == 1 {
                    //Go to step 1
                    DispatchQueue.main.async {
                        print("Presenting step 1")
                       
                            let verifiedly = UIStoryboard.init(name: "Verifiedly", bundle: Bundle(for: type(of: self)))
                            let homeVC = verifiedly.instantiateViewController(withIdentifier: "personalVC") as! PersonalViewController
                                homeVC.session = self.session
                                homeVC.modalTransitionStyle = .crossDissolve
                                homeVC.modalPresentationStyle = .overFullScreen
                                self.present(homeVC, animated: true, completion: nil)
                       
        
                    }
                } else if step == 2 {
                    //Go to step 2
                    DispatchQueue.main.async {
                        let verifiedly = UIStoryboard.init(name: "Verifiedly", bundle: Bundle(for: type(of: self)))
                            let homeVC = verifiedly.instantiateViewController(withIdentifier: "documentVC") as! SelectDocumentController
                                homeVC.session = self.session
                                homeVC.modalTransitionStyle = .crossDissolve
                                homeVC.modalPresentationStyle = .overFullScreen
                                self.present(homeVC, animated: true, completion: nil)
                       
                        
                    }
                } else if step == 3 {
                    //Go to step 3
                    DispatchQueue.main.async {
                        
                            let verifiedly = UIStoryboard.init(name: "Verifiedly", bundle: Bundle(for: type(of: self)))
                            let homeVC = verifiedly.instantiateViewController(withIdentifier: "livenessVC") as!LivenessViewController
                                homeVC.session = self.session
                                homeVC.modalTransitionStyle = .crossDissolve
                                homeVC.modalPresentationStyle = .overFullScreen
                                self.present(homeVC, animated: true, completion: nil)
                       
                        
                    }
                } else if step == 4 {
                    //Go to step 4
                    DispatchQueue.main.async {
                        
                            let verifiedly = UIStoryboard.init(name: "Verifiedly", bundle: Bundle(for: type(of: self)))
                            let homeVC = verifiedly.instantiateViewController(withIdentifier: "addressVC") as! AddressViewController
                                homeVC.session = self.session
                                homeVC.modalTransitionStyle = .crossDissolve
                                homeVC.modalPresentationStyle = .overFullScreen
                                self.present(homeVC, animated: true, completion: nil)
                     
                        
                    }
                } else if step == 5 {
                    //Go to step 5
                    guard let request_id = json!["request_id"].string else {return}
                    DispatchQueue.main.async {
                        
                            let verifiedly = UIStoryboard.init(name: "Verifiedly", bundle: Bundle(for: type(of: self)))
                            let homeVC = verifiedly.instantiateViewController(withIdentifier: "finishVC") as! FinishViewController
                                homeVC.session = self.session
                                homeVC.request_id = request_id
                                homeVC.modalTransitionStyle = .crossDissolve
                                homeVC.modalPresentationStyle = .overFullScreen
                                self.present(homeVC, animated: true, completion: nil)
                       
                        
                    }
                }

            }
            else {
                
                //The request failed for whatever reason
                RappleActivityIndicatorView.stopAnimation(completionIndicator: .failed, completionLabel: "Failed", completionTimeout: 1.0)
                let json = try? JSON(data: response.data!)
                guard let message = json!["message"].string else {return}
                let view = MessageView.viewFromNib(layout: .cardView)
                view.configureTheme(.error)
                view.button?.isHidden = true
                view.configureDropShadow()
                view.configureContent(title: "Error", body: message)
                view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
                (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
                SwiftMessages.show(view: view)

            }
                break
           // hud.dismiss(completion: nil)
            case .failure:
                RappleActivityIndicatorView.stopAnimation(completionIndicator: .failed, completionLabel: "Failed", completionTimeout: 1.0)
                print("Error getting a response")
                break
            }
        }
 
    }
    
    @IBAction func doCancel(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion:{
            let itemDict = ["isExit": "yes", "requestID": ""] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "verifiedlyDidTriggerResponse"), object: nil, userInfo: itemDict)
        //    self.verifiedly.result = "user terminated"
        })
        
    }
    @IBAction func dismissView(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: {
            let itemDict = ["isExit": "yes", "requestID": ""] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "verifiedlyDidTriggerResponse"), object: nil, userInfo: itemDict)
        })
    //    print("TEST:    "+self.verifiedly.result)
    }
    
    //Validate Session
    private func validateSession(session: String) {
        RappleActivityIndicatorView.startAnimating()
       // self.indicator.startAnimating()
        let parameters = ["session": session]
        AF.request("https://api.verified.ly/v1/mobile/validate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
         //   print(response)
            switch response.result {
            case .success:
            if response.response?.statusCode == 200 {
                RappleActivityIndicatorView.stopAnimation(completionIndicator: .success, completionLabel: "Success", completionTimeout: 1.0)
                self.termsTxt.isHidden = false
                self.agreeBtn.isHidden = false
                self.cancelBtn.isHidden = false
                self.customerTxt.isHidden = false
                self.requirement1.isHidden = false
                self.requirement2.isHidden = false
                self.requirement3.isHidden = false
                self.requirement4.isHidden = false
                self.dismissBtn.isHidden = true
            }
            else {
                
                //The request failed for whatever reason
                RappleActivityIndicatorView.stopAnimation(completionIndicator: .failed, completionLabel: "Failed", completionTimeout: 1.0)
                let json = try? JSON(data: response.data!)
                guard let message = json!["message"].string else {return}
                let view = MessageView.viewFromNib(layout: .cardView)
                view.configureTheme(.error)
                view.button?.isHidden = true
                view.configureDropShadow()
                view.configureContent(title: "Error", body: message)
                view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
                (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
                SwiftMessages.show(view: view)

            }
                break
           // hud.dismiss(completion: nil)
            case .failure:
                print("Error getting a response")
                break
            }
        }
        
    }
    

    
    //Convert hex code to uicolor
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}

