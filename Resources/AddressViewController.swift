//
//  AddressViewController.swift
//  Verifiedly
//
//  Created by Samuel Ailemen on 7/26/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import RappleProgressHUD
import SwiftMessages


class AddressViewController: UIViewController {

    var session:String = ""
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var cityTxt: UITextField!
    @IBOutlet weak var stateTxt: UITextField!
    @IBOutlet weak var zipTxt: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view1.layer.borderWidth = 0.5
        view1.layer.borderColor = UIColor.lightGray.cgColor
        
        view2.layer.borderWidth = 0.5
        view2.layer.borderColor = UIColor.lightGray.cgColor
        
        view3.layer.borderWidth = 0.5
        view3.layer.borderColor = UIColor.lightGray.cgColor
        
        view4.layer.borderWidth = 0.5
        view4.layer.borderColor = UIColor.lightGray.cgColor
        
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: {
            let itemDict = ["isExit": "yes", "requestID": ""] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "verifiedlyDidTriggerResponse"), object: nil, userInfo: itemDict)
        })
    }
    
    @IBAction func nextView(_ sender: Any) {
        guard let address = self.addressTxt.text else {return}
        guard let city = self.cityTxt.text else {return}
        guard let state = self.stateTxt.text else {return}
        guard let zip = self.zipTxt.text else {return}
        
        if !address.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty {
            //Make request
            RappleActivityIndicatorView.startAnimating()
            let parameters = ["session": session,
                              "address": address,
                              "city": city,
                              "state": state,
                              "zip": zip]
            AF.request("https://api.verified.ly/v1/mobile/kyc/step4", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
               
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
        } else {
            
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
