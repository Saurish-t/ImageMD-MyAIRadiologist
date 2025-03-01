//
//  ViewModel.swift
//  biofreeze
//
//  Created by Saurish Tripathi on 3/1/25.
//


import Foundation
import OpenAI
import UIKit

class ViewModel : ObservableObject {
    @Published var messages: [Message] = []
    @Published var currentInput: String = ""
    
    private let client = OpenAI(
        configuration: OpenAI.Configuration(
            token:"<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>", // Replace with your actual API key
            host: "https://api.openai.com/v1" // Official OpenAI API endpoint
        )
    )

    
    func sendMessage() {
        let newMessage = Message(id: UUID(), role: .user, content: currentInput)
        messages.append(newMessage)
        currentInput = ""
        
        let query = ChatQuery(
            messages: messages.map { ChatQuery.ChatCompletionMessageParam(role: $0.role, content: $0.content)! },
            // ~serverlessai:llm-large is a "virtual model", and we will automatically route your request
            // to a provider and model.
            model: "~serverlessai:llm-large"
        )
        
        Task {
            let response = try await client.chats(query: query)
            guard let receivedOpenAIMessage = response.choices.first?.message else {
                print("No message received")
                return
            }
            let receivedMessage = Message(id: UUID(), role: receivedOpenAIMessage.role, content: receivedOpenAIMessage.content!.string!)
            await MainActor.run {
                messages.append(receivedMessage)
            }
        }
    }
}


struct Message: Decodable {
    let id: UUID
    let role: ChatQuery.ChatCompletionMessageParam.Role
    let content: String
}
