//
//  RegistrationViewController.swift
//  BoloFence
//
//  Created by Luca D'Ambrosio on 03/05/2020.
//  Copyright © 2020 Luca D'Ambrosio. All rights reserved.
//

import UIKit
import Alamofire

class RegistrationViewController: UIViewController {
    
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var registerbtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
    }
    
    
    @IBAction func register(_ sender: Any) {
        
        let parameters: [String: String?] = [
            "username": username.text,
            "password": password.text,
        ]
        AF.request("http://192.168.1.67:3600/register", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                if let JSON = value as? [String: Any] {
                    let status = JSON["registration"] as! String
                    print(status)
                    if status == "true" && self.username.text?.isEmpty == false && self.password.text?.isEmpty == false  {
                        print("Utente registrato correttamente")
                        self.performSegue(withIdentifier: "segueRegistrazione", sender: self)
                    } else {
                        self.createAlert(textTitle: "Error in registration",messageText: "This username is just used in app")
                    }
                }
            case .failure( _): break
                
            }
        }
    }
    
    //ALERT
    func createAlert(textTitle: String, messageText: String) -> UIAlertController{
        let alert = UIAlertController(title: textTitle, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
        
        return alert
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "segueRegistrazione"){
            let tab = segue.destination as! UITabBarController
            let nav = tab.viewControllers?[0] as! UINavigationController
            let svc = nav.topViewController as! ViewController
            print(username.text)
            svc.user = username.text
        }
    }
}

