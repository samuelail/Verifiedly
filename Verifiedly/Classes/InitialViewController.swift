//
//  InitialViewController.swift
//  Verifiedly
//
//  Created by Samuel Ailemen on 6/21/21.
//

import UIKit



class InitialViewController: UIViewController {

    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var customerTxt: UILabel!
    @IBOutlet weak var termsTxt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //0957F9
        
        self.cancelBtn.layer.borderWidth = 0.5
        self.cancelBtn.layer.borderColor = hexStringToUIColor(hex: "0957F9").cgColor
        
        //Set active label
        
    }
    
    @IBAction func doAgree(_ sender: Any) {
        //Log agreement
        let verifiedly = UIStoryboard.init(name: "Verifiedly", bundle: Bundle(for: type(of: self)))
        let homeVC = verifiedly.instantiateViewController(withIdentifier: "personalVC")
            homeVC.modalTransitionStyle = .crossDissolve
            homeVC.modalPresentationStyle = .overFullScreen
            self.present(homeVC, animated: true, completion: nil)
    }
    
    @IBAction func doCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
