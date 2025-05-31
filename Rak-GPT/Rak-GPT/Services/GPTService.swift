//
//  GPTService.swift
//  Rak-GPT
//
//  Created by Macbook Pro on 17/05/25.
//

import Foundation

typealias completionHandler<T: Encodable> = (Result<T, APIError>) -> Void

enum APIError: Error, Equatable {
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
    
    case invalidRequest
    case limitExceed
    case noData
    case invalidData
    case noNetwork(Error)
    case parseError(Error)
}

class GPTService {
    
    public static let instance = GPTService()
    
    private init() { }
    
    private let chatDetails = "chat/completions"
    
    func fetchRequestedData(message: String, completionHandler: @escaping completionHandler<String>) {
        let urlPath = "\(Constant.Base_URL)\(chatDetails)"
        
        guard let url = URL(string: urlPath) else {
            completionHandler(.failure(.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(OPEN_Router_key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
        let param = [
                "model": "google/gemma-3n-e4b-it:free",
                "messages": [
                            ["role": "user", "content": message]
                            ]
                ] as [String : Any]

        request.httpBody = try? JSONSerialization.data(withJSONObject: param)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandler(.failure(.noNetwork(error)))
                return
            }
            guard let data = data else {
                completionHandler(.failure(.noData))
                return
            }

            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let choice = choices.first,
                   let messages = choice["message"] as? [String: Any], let text = messages["content"] as? String  {
                    DispatchQueue.main.async {
                        completionHandler(.success(text))
                    }
                }
            } else {
                completionHandler(.failure(.limitExceed))
            }
        }

        task.resume()
    }
}
