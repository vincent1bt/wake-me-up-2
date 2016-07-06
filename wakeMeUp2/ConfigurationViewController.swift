//
//  ConfigurationViewController.swift
//  wakeMeUp2
//
//  Created by vicente rodriguez on 7/5/16.
//  Copyright © 2016 vicente rodriguez. All rights reserved.
//

import UIKit
import TwitterKit

protocol ConfigurationProtocol {
    func reloadedTwitterSession(logIn: Bool)
}

class ConfigurationViewController: UIViewController {

    @IBOutlet weak var logInButton: UIButton!
    var session: String?
    var delegate: ConfigurationProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTwitter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configTwitter() {
        self.session = Twitter.sharedInstance().sessionStore.session()?.userID
        let buttonTitle = (session != nil) ? "  Cerrar sesion" : "  Iniciar sesion"
        self.logInButton.setTitle(buttonTitle, forState: .Normal)
    }
    
    @IBAction func logIn(sender: UIButton) {
        if session != nil {
            let store = Twitter.sharedInstance().sessionStore
            let UserID = store.session()?.userID
            store.logOutUserID(UserID!)
            self.delegate?.reloadedTwitterSession(false)
            self.logInButton.setTitle(" Iniciar sesion", forState: .Normal)
        }
        if session == nil {
            Twitter.sharedInstance().logInWithCompletion({ (session, error) in
                guard error == nil else {
                    return
                }
                self.delegate?.reloadedTwitterSession(true)
                self.logInButton.setTitle(" Cerrar sesion", forState: .Normal)
            })
        }
    }

}
