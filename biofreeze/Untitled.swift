import SwiftUI

struct Untitled: View {
    @ObservedObject var viewModel = ViewModel()
    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.messages.filter({$0.role != .system}), id: \.id) { message in
                    messageView(message: message)
                }
            }
            HStack {
                TextField("Write your message", text: $viewModel.currentInput)
                Button {
                    viewModel.sendMessage()
                } label: {
                    Text("Send")
                }
            }
        }
        .padding()
    }
    
    func messageView(message: Message) -> some View {
        HStack {
            if message.role == .user { Spacer(minLength: 32) }
            Text(message.content)
                .padding(10)
                .foregroundColor(message.role == .user ? Color.white : Color.black)
                .background(message.role == .user ? Color.blue : Color(red: 240/255, green: 240/255, blue: 240/255))
                .cornerRadius(10)
            if message.role == .assistant { Spacer(minLength: 32) }
        }
    }
}

#Preview {
    Untitled()
}
