//
//  QuranQuizView.swift
//  QuranOM
//
//  Created by Moody on 2024-09-22.
//

import SwiftUI

struct GuessTheSurahView: View {
    @EnvironmentObject var adAndCoinManager: AdAndCoinManager
    @StateObject private var gTSVM: GuessTheSurahViewModel = GuessTheSurahViewModel()
    
    @State private var selectedLanguage: SelectedLanguage = .arabic
    @State var isBuying: Bool = false
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                // Back Button
                Button {
                    dismiss()
                } label: {
                    Text("Back")
                        .font(.headline.bold().smallCaps())
                        .foregroundStyle(.white)
                        .frame(width: 65, height: 35)
                        .background(Color.black)
                        .cornerRadius(10.0)
                }
                
                Spacer()
                
                // Display Coins
                HStack {
                    Image("profit")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("\(adAndCoinManager.coins)")
                        .font(.title3.bold())
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            
            // Loading screen
            if gTSVM.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Fetching verse...")  // Activity indicator with message
                        .progressViewStyle(CircularProgressViewStyle())
                        .font(.headline)
                        .padding()
                    Spacer()
                }
            } else {

                if let verse = gTSVM.verse {
                    
                    ZStack {
                        // Custom rounded progress bar
                        RoundedProgressBar(progress: gTSVM.audioPlayerProgress)
                            .frame(width: UIScreen.main.bounds.size.width / 1.15, height: UIScreen.main.bounds.size.width / 1.15)
                        
                        // Play/Stop button with SF Symbols
                        Button(action: {
                            gTSVM.toggleAudioPlayback()
                        }) {
                            Image(systemName: gTSVM.isPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 25))
                                .foregroundColor(.white)
                        }
                        .frame(width: 60, height: 60)
                        .background(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                        .padding(.bottom, UIScreen.main.bounds.size.width / 1.15)
                        
                        // Display Verse
                        Text(selectedLanguage == .arabic ? verse.text : gTSVM.translation)
                            .font(.custom("NotoNaskhArabic-Regular_SemiBold", size: selectedLanguage == .arabic ? 22.0 : 14.0))
                            .multilineTextAlignment(.center)
                            .frame(width: UIScreen.main.bounds.size.width / 1.25, height: UIScreen.main.bounds.size.width / 1.25)
                            .padding()
                    }
                    
                    HStack {
                        // Show Sheikh's Name
                        Text("\(gTSVM.currentReciter)")
                            .font(.caption.smallCaps())
                            .padding(.top, -25)
                            .padding(.leading)
                            .padding(.leading)
                            .padding(.bottom)
                        
                        Spacer()
                        
                        // Toggle Shown Language
                        Text(selectedLanguage == .arabic ? "Arabic" : "English")
                            .font(.caption.smallCaps())
                            .padding(.top, -25)
                            .padding(.trailing)
                            .padding(.trailing)
                            .padding(.bottom)
                            .onTapGesture {
                                if selectedLanguage == .arabic {
                                    selectedLanguage = .english
                                } else {
                                    selectedLanguage = .arabic
                                }
                            }
                    }

                    // Display Surah choices
                    if !gTSVM.surahSelected {
                        ForEach(gTSVM.choices, id: \.self) { choice in
                            Button(action: {
                                gTSVM.checkAnswer(choice) { correct in
                                    if correct {
                                        adAndCoinManager.addCoins(10)
                                    }
                                }
                            }) {
                                Text(choice)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 55)
                                    .background(Color.black)
                                    .cornerRadius(15)
                                    .padding(.horizontal)
                            }
                            .disabled(gTSVM.surahSelected)
                        }
                        
                        Spacer()
                    }
                    
                    // Show the name of the Surah after the guess
                    if gTSVM.surahSelected {
                        VStack {
                            if gTSVM.playerAnsweredCorrectly! {
                                Text("CORRECT!")
                                    .font(.title3.bold())
                                    .padding(.top)
                                
                                Text("+10 Coins")
                                    .font(.headline)
                                    .padding(20)
                            } else {
                                Text("WRONG!")
                                    .font(.title3.bold())
                                    .padding(.top)
                                Text("Correct answer: \(gTSVM.correctAnswer)")
                                    .font(.headline)
                                    .padding(20)
                            }
                            
                            // "Next" button to move to the next question after showing feedback
                            Button(action: {
                                gTSVM.fetchRandomVerse()  // Load next question
                            }) {
                                Text("Next")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(width: 85, height: 35)
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }
                            .padding(.bottom)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(Color.black)
                        .cornerRadius(25)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                } else if let errorMessage = gTSVM.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                    
                    Button(action: {
                        gTSVM.fetchRandomVerse()
                    }) {
                        Text("Retry")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 100, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                }
            }
            // Display Banner Ad (only if ads are not removed)
            if !adAndCoinManager.areAdsRemoved {
                BannerAdView(adUnitId: "ca-app-pub-3622678098478364/5674558227")
                    .frame(width: UIScreen.main.bounds.size.width / 1.1, height: 60)  // Adjust banner size if needed
            }
        }
        .onAppear {
            gTSVM.fetchRandomVerse()
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    GuessTheSurahView()
}
