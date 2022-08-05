import UIKit

class ViewController: UIViewController {
   
    let leftOut = -400
    let rightOut = 400
    let originPosition = 0.0
    let step = 20
    var currentIndex = 0
    var toggle: Bool = true

    var arrayImages = [UIImage?]()
    var commentsLabelsArray: [UILabel] = []
    var datesLabelsArray: [UILabel] = []
    var myPost = [Post]()
    
    let decoder = JSONDecoder() // превращает данные в объект
    let encoder = JSONEncoder() // превращает объект в данные
    
    let documentFolderURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    lazy var imagesFolderURL: URL = documentFolderURL.appendingPathComponent("images")
    
    @IBOutlet weak var imageUsegHorizontalCenter: NSLayoutConstraint!
    @IBOutlet weak var imageAnotherHorizontalCenter: NSLayoutConstraint!
    @IBOutlet private weak var imageUsed: UIImageView!
    @IBOutlet private weak var imageAnother: UIImageView!
    @IBOutlet private weak var like_noactive: UIButton!
    @IBOutlet private weak var commentField: UITextField!
    @IBOutlet private weak var commentLabel: UILabel!
    @IBOutlet private weak var commentLabel1: UILabel!
    @IBOutlet private weak var commentLabel2: UILabel!
    @IBOutlet private weak var commentLabel4: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var labelDate1: UILabel!
    @IBOutlet private weak var labelDate2: UILabel!
    @IBOutlet private weak var labelDate3: UILabel!
    @IBOutlet private weak var labelDate4: UILabel!
    @IBOutlet private weak var avatarImage: UIImageView!
    @IBOutlet private weak var uploadImageButton: UIButton!
    @IBOutlet private weak var dateImageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        if FileManager.default.fileExists(atPath: imagesFolderURL.path) == false {
            try? FileManager.default.createDirectory(at: imagesFolderURL, withIntermediateDirectories: false)
        }
        
        commentField.delegate = self
        
        setAvatarImage()
        decodeArray()
        swipeGesture()
        loadImagesFromFolder()
        setupObservers()
        appendCommentsLabelsToArray()
        appendDateLabelsToArray()
        
        if arrayImages .isEmpty {
            let image = UIImage(named: "cover.jpg")
            imageUsed.image = image
            view.addSubview(imageUsed)
            
            uploadImagePicker()
        } else {
            imageUsed.image = arrayImages[currentIndex]
            dateImageLabel.text = myPost[currentIndex].imageDate
            descriptionLabel.text = myPost[currentIndex].description
            
            fillLabelsFromArray()
            fillDatesFromArray()
            setLikeImage()
        }
    }
    
    private func setAvatarImage() {     
        let image = UIImage(named: "avatar.svg")
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
        avatarImage.image = image
       
        view.addSubview(avatarImage)
    }
    
    private func appendCommentsLabelsToArray() {
        commentsLabelsArray.append(commentLabel)
        commentsLabelsArray.append(commentLabel1)
        commentsLabelsArray.append(commentLabel2)
        commentsLabelsArray.append(commentLabel4)
    }
    
    private func appendDateLabelsToArray() {
        datesLabelsArray.append(labelDate1)
        datesLabelsArray.append(labelDate2)
        datesLabelsArray.append(labelDate3)
        datesLabelsArray.append(labelDate4)
    }
    
    @IBAction func getLikeButton(_ sender: Any) {
        if toggle {
            like_noactive.setImage(UIImage(named: "heart_active.svg"), for: .normal)
            myPost[currentIndex].like = true
            encodeArray()
            toggle = false
        } else {
            like_noactive.setImage(UIImage(named: "heart.svg"), for: .normal)
            myPost[currentIndex].like = false
            encodeArray()
            toggle = true
        }
    }
    
    private func setLikeImage() {
        if myPost[currentIndex].like == true {
            like_noactive.setImage(UIImage(named: "heart_active.svg"), for: .normal)
            encodeArray()
            toggle = false
        }
        else {
            like_noactive.setImage(UIImage(named: "heart.svg"), for: .normal)
            encodeArray()
            toggle = true
        }
    }
    
    private func encodeArray() {
        do {
            let data = try encoder.encode(myPost)
            UserDefaults.standard.set(data, forKey: "myPosts")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func decodeArray() {
        if let data = UserDefaults.standard.value(forKey: "myPosts") as? Data {
            do {
                myPost = try decoder.decode([Post].self, from: data)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
        
    private func fillLabelsFromArray() {
        for lab in commentsLabelsArray {
            lab.text = ""
        }
        
        var i = 0
        for com in myPost[currentIndex].comment {
            if i <= myPost[currentIndex].comment.count {
                commentsLabelsArray[i].text = com
                i += 1
            }
        }
    }
    
    private func fillDatesFromArray() {
        for date in datesLabelsArray {
            date.text = ""
        }
        
        var i = 0
        for date in myPost[currentIndex].commentDate {
            if i <= myPost[currentIndex].commentDate.count {
                datesLabelsArray[i].text = date
                i += 1
            }
        }
    }
    
    private func loadImagesFromFolder() {
        do {
            let imageName = try FileManager.default.contentsOfDirectory(atPath: imagesFolderURL.path).filter({ $0.contains(".jpg") }).sorted()
            let imageURL = documentFolderURL.appendingPathComponent("images")
            
            for img in imageName {
                let imageNames = imageURL.appendingPathComponent(img)
                let data = try Data(contentsOf: imageNames)
                let image = UIImage(data: data)
                
                myPost[currentIndex].imageName.append(img)
                arrayImages.append(image)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func saveImagesToFolder() {
        var i = 1

        if i <= arrayImages.count {
            for image in arrayImages {
                let data = image!.pngData()
                
                do {
                    try data?.write(to: imagesFolderURL.appendingPathComponent("img\(i).jpg"))
                    i += 1
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func swipeGesture() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGestureRight))
        swipeRight.direction = .right
        self.view!.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGestureLeft))
        swipeLeft.direction = .left
        self.view!.addGestureRecognizer(swipeLeft)
    }
    
    @objc func handleGestureRight(gesture: UISwipeGestureRecognizer) -> Void {
        currentIndex += 1

        if imageUsegHorizontalCenter.constant == CGFloat(originPosition) {
            imageAnotherHorizontalCenter.constant = CGFloat(leftOut)
            
            Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { [self] timer in
                imageUsegHorizontalCenter.constant += CGFloat(step)
                imageAnotherHorizontalCenter.constant += CGFloat(step)
                
                if imageAnotherHorizontalCenter.constant == CGFloat(originPosition) {
                    timer.invalidate()
                }
            })
            
            if currentIndex < arrayImages.count {
                imageAnother.image = arrayImages[currentIndex]
                descriptionLabel.text = myPost[currentIndex].description
              
                fillLabelsFromArray()
                fillDatesFromArray()
                setLikeImage()
                dateImageLabel.text = myPost[currentIndex].imageDate
            }
            
            else {
                currentIndex = 0
                imageAnother.image = arrayImages[currentIndex]
                descriptionLabel.text = myPost[currentIndex].description
                
                fillLabelsFromArray()
                fillDatesFromArray()
                setLikeImage()
                dateImageLabel.text = myPost[currentIndex].imageDate
            }
        }
        
        else if imageAnotherHorizontalCenter.constant == CGFloat(originPosition) {
            imageUsegHorizontalCenter.constant = CGFloat(leftOut)

            Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { [self] timer in
                imageUsegHorizontalCenter.constant += CGFloat(step)
                imageAnotherHorizontalCenter.constant += CGFloat(step)
                
                if imageUsegHorizontalCenter.constant == CGFloat(originPosition) {
                    timer.invalidate()
                }
            })
            
            if currentIndex < arrayImages.count {
                imageUsed.image = arrayImages[currentIndex]
                descriptionLabel.text = myPost[currentIndex].description
                
                fillLabelsFromArray()
                fillDatesFromArray()
                setLikeImage()
                dateImageLabel.text = myPost[currentIndex].imageDate
            }
            
            else {
                currentIndex = 0
                imageUsed.image = arrayImages[currentIndex]
                descriptionLabel.text = myPost[currentIndex].description
                
                fillLabelsFromArray()
                fillDatesFromArray()
                setLikeImage()
                dateImageLabel.text = myPost[currentIndex].imageDate
            }
        }
    }
    
    @objc func handleGestureLeft(gesture: UISwipeGestureRecognizer) -> Void {
        currentIndex -= 1
            
        if imageUsegHorizontalCenter.constant == CGFloat(originPosition) {
            imageAnotherHorizontalCenter.constant = 400
            
            Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { [self] timer in
                imageUsegHorizontalCenter.constant -= CGFloat(step)
                imageAnotherHorizontalCenter.constant -= CGFloat(step)
                
                if imageAnotherHorizontalCenter.constant == CGFloat(originPosition) {
                    timer.invalidate()
                }
            })
            
            if currentIndex >= 0 {
                imageAnother.image = arrayImages[currentIndex]
                descriptionLabel.text = myPost[currentIndex].description
                
                fillLabelsFromArray()
                fillDatesFromArray()
                setLikeImage()
                dateImageLabel.text = myPost[currentIndex].imageDate
            }
            
            else {
                currentIndex = arrayImages.count - 1
                imageAnother.image = arrayImages[currentIndex]
                descriptionLabel.text = myPost[currentIndex].description
                
                fillLabelsFromArray()
                fillDatesFromArray()
                setLikeImage()
                dateImageLabel.text = myPost[currentIndex].imageDate
            }
        }
        
        else if imageAnotherHorizontalCenter.constant == CGFloat(originPosition) {
            imageUsegHorizontalCenter.constant = CGFloat(rightOut)
            
            Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { [self] timer in
                imageUsegHorizontalCenter.constant -= CGFloat(step)
                imageAnotherHorizontalCenter.constant -= CGFloat(step)
                
                if imageUsegHorizontalCenter.constant == CGFloat(originPosition) {
                    timer.invalidate()
                }
            })
            
            if currentIndex >= 0 {
                imageUsed.image = arrayImages[currentIndex]
                descriptionLabel.text = myPost[currentIndex].description
                
                fillLabelsFromArray()
                fillDatesFromArray()
                setLikeImage()
                dateImageLabel.text = myPost[currentIndex].imageDate
            }
            
            else {
                currentIndex = arrayImages.count - 1
                imageUsed.image = arrayImages[currentIndex]
                descriptionLabel.text = myPost[currentIndex].description
                
                fillLabelsFromArray()
                fillDatesFromArray()
                setLikeImage()
                dateImageLabel.text = myPost[currentIndex].imageDate
            }
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [self] notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                additionalSafeAreaInsets.bottom = keyboardFrame.height - 45
                
                view.gestureRecognizers?.removeAll()
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [self] _ in
            additionalSafeAreaInsets = .zero
            
            swipeGesture()
        }
    }
    
    private func uploadImagePicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    @IBAction func uploadButton(_ sender: Any) {
        uploadImagePicker()
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            myPost.append(Post(imageName: "", comment: [], description: "Standart description", like: false, commentDate: [], imageDate: dateFormatter.string(from: Date())))
            arrayImages.append(image)
            
            imageUsed.image = arrayImages[currentIndex]
            dateImageLabel.text = myPost[currentIndex].imageDate
            descriptionLabel.text = myPost[currentIndex].description
            setLikeImage()
             
            encodeArray()
            saveImagesToFolder()
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard commentField.text != "" else {
            return false
        }
        
        let newComment = commentField.text!
            
        if myPost[currentIndex].comment.count < commentsLabelsArray.count {
            myPost[currentIndex].comment.append(newComment)
                
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            myPost[currentIndex].commentDate.append(dateFormatter.string(from: Date()))
                
            fillLabelsFromArray()
            fillDatesFromArray()
            encodeArray()
        }
        
        commentField.text = nil
        commentField.endEditing(true)
        
        return true
    }
}
