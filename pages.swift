import SwiftUI
import GoogleGenerativeAI

struct ContentView1: View {
    @State private var age = ""
    @State private var sex = "Prefer not to answer"
    @State private var height = " "
    @State private var weight = ""
    @State private var familyHistory = ""
    @State private var showingResultPage = false
    
    let sexOptions = ["Male", "Female", "Prefer not to answer"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.purple, .blue]),
                               startPoint: .bottom,
                               endPoint: .top)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Health Risk Screening")
                        .foregroundColor(.white)
                        .bold()
                        .font(.largeTitle)
                        .padding()
                    VStack(alignment: .leading) {
                        Text("Age")
                            .foregroundColor(.white)
                            .bold()
                            .font(.title2)
                        TextField(" Enter age", text: $age)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .cornerRadius(15)
                            .frame(height: 40)
                    }
                    .padding()
                    
                    VStack(alignment: .leading) {
                        Text("Sex")
                            .foregroundColor(.white)
                            .bold()
                            .font(.title2)
                        Menu {
                            ForEach(sexOptions, id: \.self) { option in
                                Button(option) {
                                    sex = option
                                }
                            }
                        } label: {
                            HStack {
                                Text(sex)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .frame(height: 40)
                            .background(Color.white)
                            .cornerRadius(15)
                            .foregroundColor(.black)
                        }
                    }
                    .padding()
                    
                    VStack(alignment: .leading) {
                        Text("Height (in)")
                            .foregroundColor(.white)
                            .bold()
                            .font(.title2)
                        TextField(" Enter height", text: $height)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .cornerRadius(15)
                            .frame(height: 40)
                    }
                    .padding()
                    
                    VStack(alignment: .leading) {
                        Text("Weight (lbs)")
                            .foregroundColor(.white)
                            .bold()
                            .font(.title2)
                        TextField(" Enter weight", text: $weight)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .cornerRadius(15)
                            .frame(height: 40)
                    }
                    .padding()
                    
                    VStack(alignment: .leading) {
                        Text("Family History")
                            .foregroundColor(.white)
                            .bold()
                            .font(.title2)
                        TextEditor(text: $familyHistory)
                            .background(Color.white)
                            .cornerRadius(15)
                            .frame(height: 80)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button("Submit") {
                        showingResultPage = true
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showingResultPage) {
                ResultView(age: age, sex: sex, height: height, weight: weight, familyHistory: familyHistory)
            }
        }
    }
}

#Preview {
    ContentView()
}
