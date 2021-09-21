//
//  PersonalViewController.swift
//  Verifiedly
//
//  Created by Samuel Ailemen on 6/21/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import RappleProgressHUD
import SwiftMessages

class PersonalViewController: UIViewController {

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var codeView: KAPinField!
    @IBOutlet weak var selectedTxt: UILabel!
    @IBOutlet weak var ssnTxt: UITextField!
    @IBOutlet weak var numberTxt: UITextField!
    @IBOutlet weak var ssnLabel: UILabel!
    
    private var codeRequested = false
    private var countryCode:String = "US"
    var session:String = ""
    var verifiedly = Verifiedly()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.codeView.isHidden = true
        
        
        view1.layer.borderWidth = 0.5
        view1.layer.borderColor = UIColor.lightGray.cgColor
        
        view2.layer.borderWidth = 0.5
        view2.layer.borderColor = UIColor.lightGray.cgColor
        
        view3.layer.borderWidth = 0.5
        view3.layer.borderColor = UIColor.lightGray.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.addArray(_:)), name: NSNotification.Name(rawValue: "setArray"), object: nil)

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        // Do any additional setup after loading the view.
    }
    
    @objc func addArray(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            

            guard let country =  dict["countryName"] as? String else {return}
            guard let code =  dict["countryCode"] as? String else {return}
            countryCode = code.uppercased()
            self.selectedTxt.text = country
            if code.uppercased() == "US" {
                self.ssnLabel.text = "SSN"
            } else if code.uppercased() == "NG" {
                self.ssnLabel.text = "NIN"
            }
            
            
        }
        }
    
    
    @IBAction func selectCountry(_ sender: Any) {
        let verifiedly = UIStoryboard.init(name: "Verifiedly", bundle: Bundle(for: type(of: self)))
                let homeVC = verifiedly.instantiateViewController(withIdentifier: "selectVC") as! SelectCountryController
                homeVC.session = self.session
                homeVC.modalPresentationStyle = .fullScreen
                self.present(homeVC, animated: true, completion: nil)
    }
    
    @IBAction func nextView(_ sender: Any) {
        if codeRequested == false {
            //request for a phone number verification code
            guard let number = self.numberTxt.text else {return}
            if !number.isEmpty {
                self.requestCode(number: number, session: session, country: countryCode)

            }
            
            self.codeView.isHidden = true
        } else {
            //verify the code and go to the next screen
            guard let ssn = self.ssnTxt.text else {return}
            guard let code = codeView.text else {return}
            guard let number = self.numberTxt.text else {return}
            
            if !ssn.isEmpty && !code.isEmpty && !number.isEmpty {
                print(code)
                verifyCode(number: number, session: session, country: countryCode, code: code, ssn: ssn)
            }

        }
    }
    
    
    //Request for a verification code
    func requestCode(number: String, session: String, country: String) {
        RappleActivityIndicatorView.startAnimating()
        let parameters = ["session": session,
                          "country": country,
                          "phoneNumber": number]
        AF.request("https://api.verified.ly/v1/mobile/kyc/step1", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
           
            switch response.result {
            case .success:
                
                
            if response.response?.statusCode == 200 {
                RappleActivityIndicatorView.stopAnimation(completionIndicator: .success, completionLabel: "Success", completionTimeout: 1.0)
                self.codeRequested = true
                self.codeView.isHidden = false
//                let json = try? JSON(data: response.data!)
//                print(json)
               

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
    
    func verifyCode(number: String, session: String, country: String, code: String, ssn: String) {
        RappleActivityIndicatorView.startAnimating()
        let parameters = ["session": session,
                          "country": country,
                          "phoneNumber": number,
                          "code": code,
                          "ssn": ssn]
        AF.request("https://api.verified.ly/v1/mobile/kyc/step1/verify", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
           
            switch response.result {
            case .success:
            if response.response?.statusCode == 200 {
                RappleActivityIndicatorView.stopAnimation(completionIndicator: .success, completionLabel: "Success", completionTimeout: 1.0)
                let json = try? JSON(data: response.data!)
                guard let step = json!["current_step"].int else {return}
                if step == 1 {
                    //Go to step 1
                    DispatchQueue.main.async {
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
    @IBAction func dismissView(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion:{
            let itemDict = ["isExit": "yes", "requestID": ""] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "verifiedlyDidTriggerResponse"), object: nil, userInfo: itemDict)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
