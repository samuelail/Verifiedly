//
//  SelectCountryController.swift
//  Verifiedly
//
//  Created by Sonar on 3/21/21.
//  Copyright © 2021 Sonar. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RappleProgressHUD
import SwiftMessages

class SelectCountryController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {




    @IBOutlet var searchField: UITextField!
    @IBOutlet var countryCollection: UICollectionView!
    @IBOutlet var searchTxt: UITextField!
    var session:String = ""
  var Country_Name = [String]()
  var Country_Code = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Override darkmode
        self.searchField.attributedPlaceholder = NSAttributedString(string: "Search for your country",attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        
        //Load the available countries
        self.getCountry()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        // Do any additional setup after loading the view.

        

    }
    
    func getCountry() {
        RappleActivityIndicatorView.startAnimating()
        let parameters = ["session": session]
        AF.request("https://api.verified.ly/v1/mobile/kyc/get_countries", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
            switch response.result {
            case .success:
            if response.response?.statusCode == 200 {
                RappleActivityIndicatorView.stopAnimation(completionIndicator: .success, completionLabel: "Success", completionTimeout: 1.0)
                let json = try? JSON(data: response.data!)
                let contents = json!["content"]
                for i in contents.arrayValue {
                    guard let country = i["name"].string else {return}
                    guard let code = i["code"].string else {return}

                    self.Country_Name.append(country)
                    self.Country_Code.append(code)

                    self.countryCollection.reloadData()
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


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Country_Code.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = countryCollection.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CountryCell else { return UICollectionViewCell() }
        let bundle = Bundle(for: type(of: self))
        cell.countryImage.image = UIImage(named: self.Country_Code[indexPath.row], in: bundle, compatibleWith: nil)
        cell.countryName.text = self.Country_Name[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = view.frame.size.height
        let width = view.frame.size.width
        // in case you you want the cell to be 40% of your controllers view
        return CGSize(width: width * 0.5, height: height * 0.25)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")
        DispatchQueue.main.async {
            let country = self.Country_Name[indexPath.row]
            let code = self.Country_Code[indexPath.row]
            let itemDict = ["countryName": country, "countryCode": code] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "setArray"), object: nil, userInfo: itemDict)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Search countries
    @IBAction func searchCountry(_ sender: Any) {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "country_verifiedly", ofType: "json") else {return}
        let url = URL(fileURLWithPath: path)
        guard let searchTxt = self.searchTxt.text else {return}
        if !searchTxt.isEmpty {
            self.Country_Name.removeAll()
            self.Country_Code.removeAll()
            do {
                let data = try Data(contentsOf: url)
                let dataJSON = try? JSON(data: data)
                let contents = dataJSON!["content"]

                for i in contents.arrayValue {
                    guard let country = i["name"].string else {return}
                    let count = country.uppercased()
                    if count.contains(searchTxt.uppercased()) {
                        guard let code = i["code"].string else {return}
                        print("found: \(country), code: \(code)")
                        self.Country_Name.append(country)
                        self.Country_Code.append(code)

                        self.countryCollection.reloadData()
                    }

                }

            } catch {
                print("Unable to load country file")
            }
        } else {
            //Not empty
            self.Country_Name.removeAll()
            self.Country_Code.removeAll()
            
            do {
                let data = try Data(contentsOf: url)
                let dataJSON = try? JSON(data: data)
                let contents = dataJSON!["content"]
                
                for i in contents.arrayValue {
                    guard let country = i["name"].string else {return}
                    guard let code = i["code"].string else {return}
                    
                    self.Country_Name.append(country)
                    self.Country_Code.append(code)
                    
                    self.countryCollection.reloadData()
                }
                
            } catch {
                print("Unable to load country file")
            }
        }

        
    }
    
    //Dismiss Button Clicked
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
 

}
