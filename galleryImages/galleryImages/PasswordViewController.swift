import UIKit
import KeychainSwift

class PasswordViewController: UIViewController {
    
    let key = "password"
    let myPassword = "1234"
    let keychain = KeychainSwift()
    
    @IBOutlet weak var textFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keychain.set(myPassword, forKey: key)
    }
    
    @IBAction func signInButtonAction(_ sender: Any) {
        let enteredPas = textFieldPassword.text!

        guard keychain.get(key) == enteredPas else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let viewController = storyboard.instantiateViewController(identifier: "ViewController") as? ViewController
        {
            viewController.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(viewController, animated: false)
        }
    }
}
