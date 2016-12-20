//
//  LoginController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 01/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Whisper

class LoginController: UIViewController {

    // MARK: Outlets
    @IBOutlet var socialLoginView: UIView!
    @IBOutlet var mainContainer: UIView!
    @IBOutlet var txtUserName: KaedeTextField!
    @IBOutlet var txtPassword: KaedeTextField!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var btnSignInWithFacebook: UIButton!
    @IBOutlet var btnSignInWithGoogle: UIButton!
    @IBOutlet var btnForgotPassword: UIButton!
    @IBOutlet var btnSignUp: UIButton!
    @IBOutlet var btnCheckoutAsGuest: UIButton!
    @IBOutlet var socialLoginHeight: NSLayoutConstraint!
    @IBOutlet var btnCheckoutAsGuestHeight: NSLayoutConstraint!
    @IBOutlet var lblNewToApp: UILabel!
    
    var isForCheckout = false
    var needsToAddProductToFavorite = false
    var loginCompleted: (() -> ())?
    var checkoutAsGuest: (() -> ())?
    
    // MARK: Other properties
    let indicator: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 50), type: NVActivityIndicatorType.ballBeat, color: GeneralButtonColor!, padding: 0)
    
    // MARK: Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set google sign in UI delegate
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        prepareUIRelatedResources()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: LoginController()))
        
        btnCheckoutAsGuest.setTitleColor(GeneralButtonColor, for: UIControlState())
        
        if isForCheckout {
            btnCheckoutAsGuestHeight.constant = 32
        } else {
            btnCheckoutAsGuestHeight.constant = 0
        }
        
        if GoogleSignInClientId == "" && FacebookSignInClientId == "" {
            socialLoginView.isHidden = true
            socialLoginHeight.constant = 0
        }
        
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Preparing resources
    func prepareUIRelatedResources() {
        
        // Set login button UI
        btnLogin.backgroundColor = GeneralButtonColor
        
        // Set signup button UI
        btnSignUp.layer.cornerRadius = 1.0
        btnSignUp.backgroundColor = GeneralButtonColor
        
        // Set fb and google button UI
        btnSignInWithFacebook.layer.cornerRadius = 2.0
        btnSignInWithFacebook.layer.borderColor = UIColor.lightGray.cgColor
        btnSignInWithFacebook.layer.borderWidth = 1.0
        btnSignInWithFacebook.layer.masksToBounds = true

        btnSignInWithGoogle.layer.cornerRadius = 2.0
        btnSignInWithGoogle.layer.borderColor = UIColor.lightGray.cgColor
        btnSignInWithGoogle.layer.borderWidth = 1.0
        btnSignInWithGoogle.layer.masksToBounds = true
        
        // Set new to app title
        lblNewToApp.text = "New to \(ApplicationName)?"
    }
    
    func setUIElementsToAlpha(_ alpha: CGFloat) {
        indicator.center = btnLogin.center
        
        if alpha == 0.0 {
            indicator.startAnimation()
            self.view.addSubview(indicator)
        } else {
            indicator.stopAnimation()
            indicator.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.mainContainer.alpha = alpha
        }) 
    }
    
    func loginWithFacebookToken(_ token: String) {
        
        self.setUIElementsToAlpha(0.0)
        
        networkManager.loginWithFacebook(token, completion: { (success, message, response) -> (Void) in
            
            self.setUIElementsToAlpha(1.0)
            
            if success {
                if cartManager.isCartAvailable {
                    networkManager.associateCartToCurrentUser({ (success1, message2, response2) -> (Void) in
                        if success1 {
                            self.takeToNextOrPreviousScreen()
                        } else {
                            _ = SweetAlert().showAlert("Login Failed!", subTitle: "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                            customerManager.logoutCustomer()
                        }
                    })
                } else {
                    networkManager.fetchCurrentCart({ (success1, message2, response2) -> (Void) in
                        if success1 {
                            self.takeToNextOrPreviousScreen()
                        } else {
                            _ = SweetAlert().showAlert("Login Failed!", subTitle: "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                            customerManager.logoutCustomer()
                        }
                    })
                }
                
            } else {
                _ = SweetAlert().showAlert("Login Failed!", subTitle: message != nil ? message! : "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
            }
        })
    }
    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
         _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        var message = Message(title: "Please Enter valid information", backgroundColor: UIColor.red)
        
        guard !((txtUserName.text?.isEmpty)!) else {
            message.title = "Login Id can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        guard txtUserName.text!.isEmail() else {
            message.title = "Invalid Login Id."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        guard !((txtPassword.text?.isEmpty)!) else {
            message.title = "Password can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        setUIElementsToAlpha(0.0)
        
        networkManager.loginWithDetail(txtUserName.text!, password: txtPassword.text!) { (success, message, response) -> (Void) in
            
            self.setUIElementsToAlpha(1.0)
            
            if success {
                if cartManager.isCartAvailable {
                    networkManager.associateCartToCurrentUser({ (success1, message2, response2) -> (Void) in
                        if success1 {
                            self.takeToNextOrPreviousScreen()
                        } else {
                            _ = SweetAlert().showAlert("Login Failed!", subTitle: "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                            customerManager.logoutCustomer()
                        }
                    })
                } else {
                    networkManager.fetchCurrentCart({ (success1, message2, response2) -> (Void) in
                        if success1 {
                            self.takeToNextOrPreviousScreen()
                        } else {
                            _ = SweetAlert().showAlert("Login Failed!", subTitle: "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                            customerManager.logoutCustomer()
                        }
                    })
                }

            } else {
                _ = SweetAlert().showAlert("Login Failed!", subTitle: message != nil ? message! : "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
            }
        }
    }
    
    @IBAction func signInWithFacebookTapped(_ sender: UIButton) {
        
        let login = FBSDKLoginManager()
        login.loginBehavior = FBSDKLoginBehavior.systemAccount
        
        self.setUIElementsToAlpha(0.0)
        if (FBSDKAccessToken.current() != nil) {
            loginWithFacebookToken(FBSDKAccessToken.current().tokenString)
        } else {
            login.logIn(withReadPermissions: ["public_profile","email"], from: self, handler: { (result, error) in
                if error != nil {
                    self.setUIElementsToAlpha(1.0)
                    _ = SweetAlert().showAlert("Login Failed!", subTitle: "Something went wrong. Please check your internet connection and try again after a while.", style: AlertStyle.error, buttonTitle: "Ok")
                } else if (result?.isCancelled)! {
                    self.setUIElementsToAlpha(1.0)
                } else {
                    self.loginWithFacebookToken((result?.token.tokenString)!)
                }
            })
        }
    }
    
    @IBAction func signInWithGoogleTapped(_ sender: UIButton) {
        self.setUIElementsToAlpha(0.0)
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        self.navigationController?.pushViewController(UIStoryboard.forgotPasswordController()!, animated: true)
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        self.navigationController?.pushViewController(UIStoryboard.signUpController()!, animated: true)
    }

    @IBAction func btnCheckoutAsGuestTapped(_ sender: UIButton) {
        
        if isForCheckout && checkoutAsGuest != nil {
            checkoutAsGuest!()
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Utility Functions
    func takeToNextOrPreviousScreen() {
        
        if isForCheckout || needsToAddProductToFavorite {
            if loginCompleted != nil {
                loginCompleted!()
            }
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.pushViewController(UIStoryboard.myAccountController()!, animated: true)
        }
    }
}

extension LoginController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {

            setUIElementsToAlpha(0.0)
            
            networkManager.loginWithGoogle(user.authentication.idToken, completion: { (success, message, response) -> (Void) in
                
                self.setUIElementsToAlpha(1.0)
                
                if success {
                    if cartManager.isCartAvailable {
                        networkManager.associateCartToCurrentUser({ (success1, message2, response2) -> (Void) in
                            if success1 {
                                self.takeToNextOrPreviousScreen()
                            } else {
                                _ = SweetAlert().showAlert("Login Failed!", subTitle: "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                                customerManager.logoutCustomer()
                            }
                        })
                    } else {
                        networkManager.fetchCurrentCart({ (success1, message2, response2) -> (Void) in
                            if success1 {
                                self.takeToNextOrPreviousScreen()
                            } else {
                                _ = SweetAlert().showAlert("Login Failed!", subTitle: "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                                customerManager.logoutCustomer()
                            }
                        })
                    }
                    
                } else {
                    _ = SweetAlert().showAlert("Login Failed!", subTitle: message != nil ? message! : "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                }
            })
         } else {
            self.setUIElementsToAlpha(1.0)
            print("\(error.localizedDescription)")
            _ = SweetAlert().showAlert("Login Failed!", subTitle: "Something went wrong. Please check your internet connection and try again after a while.", style: AlertStyle.error, buttonTitle: "Ok")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
                withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

extension LoginController: GIDSignInUIDelegate {
    
    @nonobjc func sign(inWillDispatch signIn: GIDSignIn!, error: NSError!) {
    }
    
    func sign(_ signIn: GIDSignIn!,
                present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
                dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
}
