//
//  ViewController.swift
//  BoloFence
//
//  Created by Luca D'Ambrosio on 19/04/2020.
//  Copyright © 2020 Luca D'Ambrosio. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    @IBOutlet weak var labelUsername: UITextField!
    @IBOutlet weak var labelPassword: UITextField!
    var loginStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Gestione tastiera iPhone8
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.hideKeyboardWhenTappedAround()

    }
    
    //Calls this function when the tap is recognized.
    @objc override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func login(_ sender: Any) {
        let parameters: [String: String?] = [
            "username": labelUsername.text,
            "password": labelPassword.text,
        ]
        AF.request("http://192.168.1.67:3600/login", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let JSON = value as? [String: Any] {
                    let status = JSON["login"] as! String
                    if status == "true" {
                        print("Utente loggato correttamente")
                        self.performSegue(withIdentifier: "segue", sender: self)
                    } else {
                        print("Utente non presente nel sistema")
                        self.createAlert(textTitle: "Error in login", messageText: "Control the username or the password")
                    }
                }
            case .failure( _):
                print("Error in server!")
                self.createAlert(textTitle: "Error in server", messageText: "Oops!! There is server error!")
                
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
        if(segue.identifier == "segue"){
            let tab = segue.destination as! UITabBarController
            let nav = tab.viewControllers?[0] as! UINavigationController
            let svc = nav.topViewController as! ViewController
            svc.user = labelUsername.text
        }
    }
}

//Extension tastira app
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
