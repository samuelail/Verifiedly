//
//  LicenseBackController.swift
//  Verifiedly
//
//  Created by Samuel Ailemen on 7/21/21.
//

import UIKit
import AVFoundation
import Alamofire
import RappleProgressHUD
import SwiftMessages
import SwiftyJSON

class LicenseBackController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    
    var session:String = ""
    var selectedImg = Data()
    @IBOutlet weak var previewLayer: UIView!
    
    //Declare camera objects
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        //Gain access to the back camera
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()

            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
            
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            //Step 13
        }
        
        //Detecting the barcode
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
                   captureSession.addOutput(metadataOutput)

                   metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.pdf417]
               } else {
                  print("failed")
                   return
               }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

       // dismiss(animated: true)
    }

    func found(code: String) {
        print(code)
        self.addDocument(selectedImg: selectedImg, code: code)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    @IBAction func dismissView(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: {
            let itemDict = ["isExit": "yes", "requestID": ""] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "verifiedlyDidTriggerResponse"), object: nil, userInfo: itemDict)
        })
    }
    
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        self.previewLayer.layer.addSublayer(videoPreviewLayer)
        //self.videoPreviewLayer.
        
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = self.previewLayer.bounds
        }
        
    }
    
    func addDocument(selectedImg: Data, code: String) {
        RappleActivityIndicatorView.startAnimating()
        let headers: HTTPHeaders = [
           
            "Content-Type": "multipart/form-data"
        ]
        
        let parameters: Parameters = [
            "session": self.session,
            "data": code]
//
//        guard  let imageData = selectedImg.fileda
    AF.upload(multipartFormData: { (multipartFormData) in
        multipartFormData.append(selectedImg, withName: "document", fileName: "profile_pic.png", mimeType: "image/png")
        for (key, value) in parameters {
            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
        }
    }, to: "https://api.verified.ly/v1/mobile/kyc/step2/license", method: .post, headers: headers).responseJSON { response in
       
        //
                        switch response.result {

                        case .success:
                            if response.response?.statusCode == 200 {
                                RappleActivityIndicatorView.stopAnimation(completionIndicator: .success, completionLabel: "Success", completionTimeout: 1.0)
                                //The request was successful
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
                                //The request failed
                                //The request failed for whatever reason
                                self.captureSession.startRunning()
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
                                self.dismiss(animated: true, completion: nil)
                           
                            }


                            break

                        case .failure:
                            RappleActivityIndicatorView.stopAnimation(completionIndicator: .failed, completionLabel: "Failed", completionTimeout: 1.0)
                            print("Error getting a response")
                            break

                        }
    }
    }

}
