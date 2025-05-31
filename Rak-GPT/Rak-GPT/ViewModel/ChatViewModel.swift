//
//  ChatViewModel.swift
//  Rak-GPT
//
//  Created by Macbook Pro on 17/05/25.
//


import Foundation

class ChatViewModel {
    var chatArray: [Chat] = []
    var isLoading = false
    var collectionItems = [
                Plan(title: "Try fix bug from your code", descriptor: "Fix my bug from below code. I can't find where ta the issue. Do it in detais and explain me why it happens"),
                Plan(title: "Write a content", descriptor: "Write a small content for my publishing book elaborating"),
                Plan(title: "Make a presentation on", descriptor: "Help me to create a presentation on the current situations on global economy")
                ]
    
    var plansItems = [
        Plan(title: "Find bug", descriptor: "Help me to find a bug in my code I will provide"),
        Plan(title: "Recipe", descriptor: "Create some good recipe for my kitchen"),
        Plan(title: "Write a note", descriptor: "write a thank you note to my interviewer")
    ]
    
    var onReceiveReply: ((_ : String? ) -> Void)?
    var onError: ((String) -> Void)?
    
    func setUserChat() {
        if let chatData = DataManager.instsnce.retrieveChat() {
            self.chatArray = chatData
            self.onReceiveReply?(nil)
        }
    }
    
    func generateResponse(message: String) {
        guard !message.isEmpty else { return }
        self.chatArray.append(Chat(userType: .User, message: message))
        self.onReceiveReply?(nil)
        
        GPTService.instance.fetchRequestedData(message: message, completionHandler: { result in
            switch result {
            case .failure(let error) :
                self.onError?(error.localizedDescription)
                break
            case .success(let reply):
                self.chatArray.append(Chat(userType: .Bot, message: reply))
                DataManager.instsnce.saveChatModels(self.chatArray)
                self.onReceiveReply?(reply)
                break
            }
        })
    }
    
    func resetAllChat() {
        self.chatArray = []
        self.onReceiveReply?(nil)
    }
}
