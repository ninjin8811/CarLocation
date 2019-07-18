//
//  LoginViewController.swift
//  CarLocation
//
//  Created by 吉野史也 on 2019/07/18.
//  Copyright © 2019 yoshinofumiya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Auto Login
        if let userData = UserDefaults.standard.dictionary(forKey: "userData") {
            
            Auth.auth().signIn(withEmail: userData["userID"] as! String, password: userData["password"] as! String, completion: { (result, error) in
                if error != nil {
                    print("自動ログインに失敗しました")
                } else {
                    print("自動ログインしました")
                    self.performSegue(withIdentifier: "goToAdminMenuView", sender: self)
                }
            })
        }
    }
    

    @IBAction func loginButtonPressed(_ sender: Any) {
        SVProgressHUD.show()
        
        guard let uid = idTextField.text else {
            preconditionFailure("ユーザーIDが空欄です")
        }
        let loginID = uid + "@gmail.com"
        
        loginFirebase(loginID)
    }
    
    func loginFirebase(_ loginID: String) {
        Auth.auth().signIn(withEmail: loginID, password: passwordTextField.text!) { _, error in
            if error != nil {
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "ログイン失敗", message: "メールアドレスまたはパスワードが有効ではありません", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                
                print("ログインに失敗しました")
            } else {
                SVProgressHUD.dismiss()
                
                let ud = UserDefaults.standard
                let userDataDictionary: [String: String] = ["userID": loginID, "password": self.passwordTextField.text!]
                ud.set(userDataDictionary, forKey: "userData")
                self.performSegue(withIdentifier: "goToAdminMenuView", sender: self)
            }
        }
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
