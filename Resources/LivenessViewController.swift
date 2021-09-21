//
//  LivenessViewController.swift
//  Verifiedly
//
//  Created by Samuel Ailemen on 7/22/21.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import RappleProgressHUD
import SwiftMessages


class LivenessViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var previewLayer: UIView!
    
    var session:String = ""
    
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
        guard let device = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else {return}

        do {
            let input = try AVCaptureDeviceInput(device: device)
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
        
  
    }
    
 
    @IBAction func dismissView(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: {
            let itemDict = ["isExit": "yes", "requestID": ""] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "verifiedlyDidTriggerResponse"), object: nil, userInfo: itemDict)
        })
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
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

    @IBAction func capturePhoto(_ sender: Any) {
        if #available(iOS 11.0, *) {
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            stillImageOutput.capturePhoto(with: settings, delegate: self)
        } else {
            // Fallback on earlier versions
        }
    }
    
    //Handle captured photo
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
        else { return }
        
        let image = UIImage(data: imageData)
        print(image!)
        self.captureSession.stopRunning()
            
        self.addFace(selectedImg: imageData)
    }
    
    func addFace(selectedImg: Data) {
        RappleActivityIndicatorView.startAnimating()
        let headers: HTTPHeaders = [
           
            "Content-Type": "multipart/form-data"
        ]
        
        let parameters: Parameters = [
            "session": self.session]
//
//        guard  let imageData = selectedImg.fileda
    AF.upload(multipartFormData: { (multipartFormData) in
        multipartFormData.append(selectedImg, withName: "document", fileName: "face.png", mimeType: "image/png")
        for (key, value) in parameters {
            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
        }
    }, to: "https://api.verified.ly/v1/mobile/kyc/step3", method: .post, headers: headers).responseJSON { response in
       
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
