import UIKit

class PasswordViewController: UIViewController {
    
    let key = "password"
    @IBOutlet weak var textFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set("1234", forKey: key)
    }
    
    @IBAction func signInButtonAction(_ sender: Any) {
        let enteredPas = textFieldPassword.text!
        
        if UserDefaults.standard.object(forKey: key) as! String == enteredPas {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            if let viewController = storyboard.instantiateViewController(identifier: "ViewController") as? ViewController {
                viewController.modalPresentationStyle = .fullScreen
                navigationController?.pushViewController(viewController, animated: false)
            }
        }
    }
}
