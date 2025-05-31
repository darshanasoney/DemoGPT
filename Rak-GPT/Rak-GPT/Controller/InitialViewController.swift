//
//  InitialViewController.swift
//  Rak-GPT
//
//  Created by Macbook Pro on 18/05/25.
//

import UIKit

class InitialViewController: UIViewController {
    
    @IBOutlet weak var loaderView : UIImageView!
    let recognizer = SpeechRecognizer()
    let viewModel = ChatViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recognizer.onTextUpdate = { [weak self] text in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
                    vc.recognizedText = text
                    if let _ = self.navigationController?.viewControllers.contains(where: { vc in
                        return vc.isKind(of: ChatViewController.self)
                    }) {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        
    }
    
    @IBAction func micTapped(_ sender: UIButton) {
        guard let gifPath = Bundle.main.path(forResource: "microphone", ofType: "gif") else {
            print("Failed to find the GIF image.")
            return
        }
        
        guard let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)) else {
            print("Failed to load the GIF image data.")
            return
        }
        
        guard let gifImage = UIImage.gifImageWithData(gifData) else {
            print("Failed to create the GIF image.")
            return
        }
        
        loaderView.image = gifImage
        
        recognizer.startSpeechRecognisation()
    }
    
    @IBAction func googleLoginTapped(_ sender: UIButton) {
        self.createUser()
        self.pushViewController(identifier: "ChatViewController")
    }
    
    @IBAction func SignUpTapped(_ sender: UIButton) {
        self.createUser()
        self.pushViewController(identifier: "ChatViewController")
    }
    
    @IBAction func LoginWithExistingTapped(_ sender: UIButton) {
        self.createUser()
        self.pushViewController(identifier: "ChatViewController")
    }
    
    func createUser() {
        let user = User(name: "Nikkie", address: "Banglore", role: "Normal")
        DataManager.instsnce.saveUserModels(user)
    }
    
    deinit {
        recognizer.onTextUpdate = nil
    }
}

class DataManager {
    
    static let instsnce = DataManager()
    
    private init() {}
    
    private let userDefaultsKey = "userModels"
    private let chatKey = "chatModels"
    
    func saveUserModels(_ model: User) {
        do {
            let data = try JSONEncoder().encode(model)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to encode model: \(error)")
        }
    }
    
    func retrieveUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return nil
        }
        do {
            let models = try JSONDecoder().decode(User.self, from: data)
            return models
        } catch {
            print("Failed to decode model: \(error)")
            return nil
        }
    }
    
    func saveChatModels(_ model: [Chat]) {
        do {
            let data = try JSONEncoder().encode(model)
            UserDefaults.standard.set(data, forKey: chatKey)
        } catch {
            print("Failed to encode model: \(error)")
        }
    }
    
    func retrieveChat() -> [Chat]? {
        guard let data = UserDefaults.standard.data(forKey: chatKey) else {
            return nil
        }
        do {
            let models = try JSONDecoder().decode([Chat].self, from: data)
            return models
        } catch {
            print("Failed to decode model: \(error)")
            return nil
        }
    }
}


