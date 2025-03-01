//
//  OnboardingView.swift
//  biofreeze
//
//  Created by Saurish Tripathi on 3/1/25.
//


import SwiftUI
import AVFoundation

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    @State private var gradientColors: [Color] = [Color.purple, Color.blue]

    struct OnboardingPage {
        let title: String
        let description: String
        let imageName: String
    }
    
    let pages: [OnboardingPage] = [
        OnboardingPage(title: "Welcome to imageMD", description: "Harness AI-driven insights for faster and more accurate radiology analysis.", imageName: "waveform.path.ecg"),
        OnboardingPage(title: "AI-Powered Image Analysis", description: "Detect anomalies and get instant insights with our advanced AI models.", imageName: "brain.head.profile"),
        OnboardingPage(title: "Seamless Workflow Integration", description: "Analyze your own x-ray scans with our Tools", imageName: "rectangle.3.group.fill"),
        OnboardingPage(title: "Get Started!", description: "Let’s revolutionize radiology together. Start now!", imageName: "arrow.right.circle.fill")
    ]


    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: pages[currentPage].imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .transition(.opacity)

                Text(pages[currentPage].title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .transition(.opacity)

                Text(pages[currentPage].description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .transition(.opacity)
                
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \..self) { index in
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(index == currentPage ? .white : .white.opacity(0.5))
                    }
                }

                Button(action: nextPage) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .cornerRadius(25)
                        .shadow(radius: 10)
                }
                .padding(.horizontal, 40)
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                Spacer()
            }
            .padding()
            .transition(.opacity)
        }
        .animation(.spring(), value: currentPage)
    }

    func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
            gradientColors = gradientColors.reversed()
        } else {
            hasSeenOnboarding = true
        }
    }
}
