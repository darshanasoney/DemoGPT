//
//  ChatViewController.swift
//  Rak-GPT
//
//  Created by Macbook Pro on 18/05/25.
//

import UIKit

class ChatViewController: UIViewController {
    
    @IBOutlet weak var recognizedTextField: UITextField!
    @IBOutlet weak var loaderView : UIImageView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var userNameLable: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var suggestionCollectionView : UICollectionView!
    @IBOutlet weak var chatTableView : UITableView!
    @IBOutlet weak var optionsCollectionView : UICollectionView!
    @IBOutlet weak var optionsCollectionViewHeight : NSLayoutConstraint!
    
    let viewModel = ChatViewModel()
    let recognizer = SpeechRecognizer()
    
    var recognizedText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !recognizedText.isEmpty {
            self.recognizedTextField.text = recognizedText
            
            self.sendChatRequest()
        }
        self.viewModel.setUserChat()
    }
    
    func setUI() {
        if let user = DataManager.instsnce.retrieveUser() {
            self.userNameLable.text = "Hello \(user.name)"
        }
        
        self.recognizedTextField.delegate = self
        self.sendButton.isHidden = true
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        suggestionCollectionView.dataSource = self
        optionsCollectionView.dataSource = self
        
        optionsCollectionView.collectionViewLayout = layout
        optionsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        optionsCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        
        optionsCollectionView.delegate = self
        suggestionCollectionView.register(UINib(nibName: "suggestionCollectionViewCell", bundle: nil),  forCellWithReuseIdentifier: "suggestionCollectionViewCell")
        
        chatTableView.register(UINib(nibName: "chatSenderTableViewCell", bundle: nil), forCellReuseIdentifier: "chatSenderTableViewCell")
        chatTableView.register(UINib(nibName: "chatBotTableViewCell", bundle: nil), forCellReuseIdentifier: "chatBotTableViewCell")
        
        guard let gifPath = Bundle.main.path(forResource: "loader", ofType: "gif") else {
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
    }
    
    func setBindings() {
        viewModel.onReceiveReply = { [weak self] reply in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.chatTableView.isHidden = !(self.viewModel.chatArray.count > 0)
                self.resetButton.isHidden = false
                self.chatTableView.reloadData()
                self.setSendButton()
                self.sendButton.isEnabled = true
                self.micButton.isEnabled = true
                if reply != nil {
                    self.loaderView.isHidden = true
                    self.scrollToBottom()
                }
            }
        }
        
        viewModel.onError = { [weak self] error in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.chatTableView.isHidden = true
                self.showErrorAlert(message: error)
            }
        }
        
        recognizer.onTextUpdate = { [weak self] text in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.recognizedTextField.text = text
                self.sendButton.isEnabled = !text.isEmpty
                self.sendButton.isHidden = text.isEmpty
                self.micButton.isHidden = !text.isEmpty
            }
        }
    }
    
    @IBAction func micButtonTapped(_ sender: UIButton) {
        recognizer.startSpeechRecognisation()
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        self.recognizedTextField.text = ""
        self.loaderView.isHidden = true
        viewModel.resetAllChat()
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        self.sendChatRequest()
    }
    
    func sendChatRequest() {
        self.loaderView.isHidden = false
        self.view.endEditing(true)
        guard let message = recognizedTextField.text else { return }
        recognizer.recognizedText = ""
        recognizedTextField.text = ""
        self.sendButton.isEnabled = false
        self.micButton.isEnabled = false
        
        viewModel.generateResponse(message: message)

    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Rak-GPT", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .cancel)
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true)
    }
    
    func setSendButton() {
        if recognizedTextField.text?.isEmpty ?? false {
            self.sendButton.isHidden = true
            self.micButton.isHidden = false
        } else {
            self.sendButton.isHidden = false
            self.micButton.isHidden = true
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func scrollToBottom() {
        let lastRow = max(0, viewModel.chatArray.count - 1)
        let indexPath = IndexPath(row: lastRow, section: 0)
        chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chatArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chat = viewModel.chatArray[indexPath.row]
        
        if chat.userType == .Bot {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatBotTableViewCell") as? chatBotTableViewCell else { return UITableViewCell() }
            
            cell.populate(chat: chat)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "chatSenderTableViewCell") as? chatSenderTableViewCell else { return UITableViewCell() }
            
            cell.populate(chat: chat)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            self.setSendButton()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.setSendButton()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.setSendButton()
    }
    
}

extension ChatViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.optionsCollectionView {
            return viewModel.collectionItems.count
        } else {
            return viewModel.plansItems.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.optionsCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell {
                cell.populate(plan: viewModel.collectionItems[indexPath.row])
                
                cell.onEditClicked = { item in
                    self.recognizedTextField.text = item.descriptor
                    self.setSendButton()
                }
                
                cell.onGetAnswerClicked = { item in
                    self.recognizedTextField.text = item.descriptor
                    self.setSendButton()
                    self.sendChatRequest()
                }
                
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestionCollectionViewCell", for: indexPath) as? suggestionCollectionViewCell {
                cell.populate(plan: viewModel.plansItems[indexPath.row])
                
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.optionsCollectionView {
            let width = collectionView.bounds.width - 80
            
            return CGSize(width: width, height: 180)
        }
        return CGSize(width: 35, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == suggestionCollectionView {
            let item = viewModel.plansItems[indexPath.row]
            
            self.recognizedTextField.text = item.descriptor
            setSendButton()
            self.sendChatRequest()
        }
    }
    
    // MARK: - ScrollView Delegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == optionsCollectionView {
//            highlightCenteredItems()
        }
    }

    func highlightCenteredItems() {
        let centerX = optionsCollectionView.bounds.size.width / 2 + optionsCollectionView.contentOffset.x

        var distances: [(index: IndexPath, distance: CGFloat)] = []

        for cell in optionsCollectionView.visibleCells {
            if let indexPath = optionsCollectionView.indexPath(for: cell) {
                let attributes = optionsCollectionView.layoutAttributesForItem(at: indexPath)
                let cellCenterX = attributes?.center.x ?? 0
                let distance = abs(centerX - cellCenterX)
                distances.append((indexPath, distance))
            }
        }

        // Sort by center
        let highlightIndexes = distances.sorted(by: { $0.distance < $1.distance }).prefix(2).map { $0.index }

        optionsCollectionView.visibleCells.forEach { cell in
            if let indexPath = optionsCollectionView.indexPath(for: cell) {
                if highlightIndexes.contains(indexPath) {
                    UIView.animate(withDuration: 0.4) {
                        cell.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                    }
                } else {
                    UIView.animate(withDuration: 0.4) {
                        cell.transform = .identity
                    }
                }
            }
        }
    }
}

extension ChatViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.setSendButton()
        self.view.endEditing(true)
    }
    
}

extension UIImage {
    class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        let frameCount = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        
        for i in 0..<frameCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let image = UIImage(cgImage: cgImage)
                images.append(image)
            }
        }
        
        return UIImage.animatedImage(with: images, duration: 0.0)
    }
}
