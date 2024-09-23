//
//  MainMenu.swift
//  QuranOM
//
//  Created by Moody on 2024-09-23.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject private var adAndCoinManager = AdAndCoinManager()
    @State private var isBuying: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isBuying {
                    VStack {
                        Spacer()
                        ZStack {
                            // Window
                            ZStack (alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 25.0)
                                    .foregroundStyle(.black)
                                    .frame(width: UIScreen.main.bounds.size.width / 1.15, height: UIScreen.main.bounds.size.height / 2.0)
                                Button(action: {
                                    isBuying = false
                                }) {
                                    Image(systemName: "cross.fill")
                                        .font(.system(size: 25))
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(45))
                                }
                                .frame(width: 60, height: 60)
                                .background(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                .padding(10)
                            }
                            
                            // Buttons
                            VStack {
                                Text("Remove Ads for $0.99 or 1000 coins")
                                    .font(.headline.bold().smallCaps())
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .frame(width: UIScreen.main.bounds.size.width / 1.25)
                                    .padding()
                                
                                HStack {
                                    Button(action: {
                                        Task {
                                            await adAndCoinManager.purchaseRemoveAds()
                                        }
                                    }) {
                                        Text("$0.99")
                                            .font(.headline.bold().smallCaps())
                                            .foregroundColor(.black)
                                            .frame(width: UIScreen.main.bounds.size.width / 3, height: 55)
                                            .background(Color.white)
                                            .cornerRadius(15)
                                            .padding(.horizontal)
                                    }
                                    .disabled(adAndCoinManager.areAdsRemoved)
                                    
                                    
                                    Button(action: {
                                        adAndCoinManager.removeAdsWithCoins()
                                    }) {
                                        Text("1000 coins")
                                            .font(.headline.bold().smallCaps())
                                            .foregroundColor(.black)
                                            .frame(width: UIScreen.main.bounds.size.width / 3, height: 55)
                                            .background(Color.white)
                                            .cornerRadius(15)
                                            .padding(.horizontal)
                                    }
                                    .disabled(adAndCoinManager.areAdsRemoved)
                                }
                                
                                Button(action: {
                                    Task {
                                        await adAndCoinManager.restorePurchases()
                                    }
                                }) {
                                    Text("Restore")
                                        .font(.headline.bold().smallCaps())
                                        .foregroundColor(.black)
                                        .frame(width: UIScreen.main.bounds.size.width / 3, height: 55)
                                        .background(Color.white)
                                        .cornerRadius(15)
                                        .padding(.horizontal)
                                        .padding(.top)
                                }
                                .disabled(adAndCoinManager.areAdsRemoved)
                                
                                Text(adAndCoinManager.errorMessage)
                                    .font(.headline.bold().smallCaps())
                                    .foregroundColor(.red)
                                    .frame(height: 55)
                                    .padding(.top)
                            }
                        }
                        .onAppear {
                            adAndCoinManager.errorMessage = ""
                        }
                        
                        Spacer()
                    }
                } else {
                    HStack {
                        // Display Coins
                        HStack {
                            Image("profit")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("\(adAndCoinManager.coins)")
                                .font(.title3.bold())
                        }
                        
                        Spacer()
                        
                        // Title
                        Text("QuranOM")
                            .font(.largeTitle.bold())
                        
                        Spacer()
                        
                        // No Ads Button
                        if !adAndCoinManager.areAdsRemoved {
                            Image("blocked")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    isBuying = true
                                }
                                .disabled(isBuying)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    NavigationLink {
                        GuessTheSurahView()
                            .environmentObject(adAndCoinManager)
                    } label: {
                        Text("Guess the Surah")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(Color.black)
                            .cornerRadius(15)
                            .padding(.bottom, 20)
                    }
                    
                    NavigationLink {
                        GuessTheNextVerseView()
                            .environmentObject(adAndCoinManager)
                    } label: {
                        Text("Guess the Next Verse")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(Color.black)
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                    }
                    
                    Spacer()
                    
                    // Display Banner Ad (only if ads are not removed)
                    if !adAndCoinManager.areAdsRemoved {
                        BannerAdView(adUnitId: "ca-app-pub-3622678098478364/5674558227")
                            .frame(width: UIScreen.main.bounds.size.width / 1.1, height: 60)  // Adjust banner size if needed
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    MainMenuView()
}
