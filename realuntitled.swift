import SwiftUI

struct ChatbotView: View {
    @State private var userInput: String = ""
    @State private var chatHistory: [(String, String)] = []
    
    private let apiKey = "sk-proj-aVYLU8m6MsMhwyQNbZxGT3BlbkFJG6fhOybvRgPCuxca568O"
    
    var body: some View {
        VStack {
            Text("Talk to xrAI")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(chatHistory, id: \.0) { chat in
                        HStack {
                            Text("You: \(chat.0)")
                                .foregroundColor(.blue)
                                .padding(5)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            Spacer()
                        }
                        
                        HStack {
                            Text("xrAI: \(chat.1)")
                                .foregroundColor(.green)
                                .padding(5)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            Spacer()
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Type your message", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .frame(maxHeight: 50)
                
                Button(action: sendMessage) {
                    Text("Send")
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.trailing)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sendMessage() {
        guard !userInput.isEmpty else { return }
        
        let userMessage = userInput
        let currentUserInput = userInput
        userInput = ""
  
        chatHistory.append((currentUserInput, ""))
        
   
        fetchBotResponse(for: currentUserInput)
    }
    
    private func fetchBotResponse(for message: String) {

        let fixedResponse = "Based of your response of being a 15 year old male and our holistic AI review, it looks like you may have pneumonia. I suggest you consult with a doctor for further analysis and treatment. Hope you feel better soon! "
        
      
        DispatchQueue.main.async {
            chatHistory[chatHistory.count - 1] = (message, fixedResponse)
        }
    }
}

struct Untitled: View {
    var body: some View {
        NavigationView {
            ChatbotView()
        }
    }
}

