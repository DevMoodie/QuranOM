//
//  QuranQuizViewModel.swift
//  QuranOM
//
//  Created by Moody on 2024-09-22.
//

import Combine
import AVFoundation

class GuessTheSurahViewModel: ObservableObject {
    @Published var errorMessage: String?
    
    // Quiz
    @Published var choices: [String] = []
    @Published var correctAnswer: String = ""
    @Published var surahSelected: Bool = false
    
    @Published var playerAnsweredCorrectly: Bool?
    
    //MARK: - Quiz
    
    // Fetching Verse
    @Published var verse: Verse?
    @Published var isLoading: Bool = false
    
    var cancellables = Set<AnyCancellable>()
    
    let reciters = [
        ("ar.alafasy", "Mishary Rashid Alafasy"),
        ("ar.husary", "Mahmoud Khalil Al-Husary"),
        ("ar.abdulbasitmurattal", "Abdul Basit Abdul Samad"),
        ("ar.saoodshuraym", "Saud Al-Shuraim"),
        ("ar.ahmedajamy", "Ahmad Al-Ajmy"),
        ("ar.minshawi", "Mohamed Siddiq Al-Minshawi"),
        ("ar.abdurrahmaansudais", "Abdul Rahman Al-Sudais"),
        ("ar.mahermuaiqly", "Maher Al-Muaiqly"),
        ("ar.shaatree", "Abu Bakr Al-Shatri")
    ]
    
    @Published var currentReciter: String = ""
    
    @Published var translation: String = ""
    
    func fetchRandomVerse() {
        isLoading = true  // Start loading
        
        // Reset Buttons
        surahSelected = false
        playerAnsweredCorrectly = nil
        
        let randomVerseNumber = Int.random(in: 1...6236)
        let randomReciter = reciters.randomElement()!
        let reciterCode = randomReciter.0
        currentReciter = randomReciter.1  // Set the Sheikh's name
        
        let arabicVerseURL = "https://api.alquran.cloud/v1/ayah/\(randomVerseNumber)/\(reciterCode)"
        let translationURL = "https://api.alquran.cloud/v1/ayah/\(randomVerseNumber)/en.itani"
        
        guard let arabicURL = URL(string: arabicVerseURL) else {
            errorMessage = "Invalid URL"
            isLoading = false  // Stop loading
            return
        }
        
        guard let englishURL = URL(string: translationURL) else {
            errorMessage = "Invalid URL"
            isLoading = false  // Stop loading
            return
        }
        
        let arabicPublisher = URLSession.shared.dataTaskPublisher(for: arabicURL)
            .map { $0.data }
            .decode(type: QuranAPIResponse.self, decoder: JSONDecoder())

        let translationPublisher = URLSession.shared.dataTaskPublisher(for: englishURL)
            .map { $0.data }
            .decode(type: EnglishQuranAPIResponse.self, decoder: JSONDecoder())
        
        // Combine both API requests
        Publishers.Zip(arabicPublisher, translationPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Failed to fetch verse: \(error.localizedDescription)"
                case .finished:
                    break
                }
                self.isLoading = false
            }, receiveValue: { [weak self] arabicVerse, verseTranslation in
                self?.verse = arabicVerse.data
                self?.translation = verseTranslation.data.text
                self?.correctAnswer = arabicVerse.data.surah.englishName
                self?.generateChoices(correctSurah: arabicVerse.data.surah.englishName)
            })
            .store(in: &cancellables)
    }
    
    func generateChoices(correctSurah: String) {
        var allSurahs = [
            "Al-Fatiha",        // 1
            "Al-Baqarah",       // 2
            "Aal-E-Imran",      // 3
            "An-Nisa",          // 4
            "Al-Maidah",        // 5
            "Al-An'am",         // 6
            "Al-A'raf",         // 7
            "Al-Anfal",         // 8
            "At-Tawbah",        // 9
            "Yunus",            // 10
            "Hud",              // 11
            "Yusuf",            // 12
            "Ar-Ra'd",          // 13
            "Ibrahim",          // 14
            "Al-Hijr",          // 15
            "An-Nahl",          // 16
            "Al-Isra",          // 17
            "Al-Kahf",          // 18
            "Maryam",           // 19
            "Ta-Ha",            // 20
            "Al-Anbiya",        // 21
            "Al-Hajj",          // 22
            "Al-Mu'minun",      // 23
            "An-Nur",           // 24
            "Al-Furqan",        // 25
            "Ash-Shu'ara",      // 26
            "An-Naml",          // 27
            "Al-Qasas",         // 28
            "Al-Ankabut",       // 29
            "Ar-Rum",           // 30
            "Luqman",           // 31
            "As-Sajda",         // 32
            "Al-Ahzab",         // 33
            "Saba",             // 34
            "Fatir",            // 35
            "Ya-Sin",           // 36
            "As-Saffat",        // 37
            "Sad",              // 38
            "Az-Zumar",         // 39
            "Ghafir",           // 40
            "Fussilat",         // 41
            "Ash-Shura",        // 42
            "Az-Zukhruf",       // 43
            "Ad-Dukhan",        // 44
            "Al-Jathiya",       // 45
            "Al-Ahqaf",         // 46
            "Muhammad",         // 47
            "Al-Fath",          // 48
            "Al-Hujurat",       // 49
            "Qaf",              // 50
            "Adh-Dhariyat",     // 51
            "At-Tur",           // 52
            "An-Najm",          // 53
            "Al-Qamar",         // 54
            "Ar-Rahman",        // 55
            "Al-Waqi'a",        // 56
            "Al-Hadid",         // 57
            "Al-Mujadila",      // 58
            "Al-Hashr",         // 59
            "Al-Mumtahina",     // 60
            "As-Saff",          // 61
            "Al-Jumu'a",        // 62
            "Al-Munafiqun",     // 63
            "At-Taghabun",      // 64
            "At-Talaq",         // 65
            "At-Tahrim",        // 66
            "Al-Mulk",          // 67
            "Al-Qalam",         // 68
            "Al-Haqqah",        // 69
            "Al-Ma'arij",       // 70
            "Nuh",              // 71
            "Al-Jinn",          // 72
            "Al-Muzzammil",     // 73
            "Al-Muddathir",     // 74
            "Al-Qiyama",        // 75
            "Al-Insan",         // 76
            "Al-Mursalat",      // 77
            "An-Naba",          // 78
            "An-Nazi'at",       // 79
            "Abasa",            // 80
            "At-Takwir",        // 81
            "Al-Infitar",       // 82
            "Al-Mutaffifin",    // 83
            "Al-Inshiqaq",      // 84
            "Al-Buruj",         // 85
            "At-Tariq",         // 86
            "Al-A'la",          // 87
            "Al-Ghashiyah",     // 88
            "Al-Fajr",          // 89
            "Al-Balad",         // 90
            "Ash-Shams",        // 91
            "Al-Layl",          // 92
            "Ad-Duhaa",         // 93
            "Ash-Sharh",        // 94
            "At-Tin",           // 95
            "Al-Alaq",          // 96
            "Al-Qadr",          // 97
            "Al-Bayyina",       // 98
            "Az-Zalzalah",      // 99
            "Al-Adiyat",        // 100
            "Al-Qari'a",        // 101
            "At-Takathur",      // 102
            "Al-Asr",           // 103
            "Al-Humazah",       // 104
            "Al-Fil",           // 105
            "Quraish",          // 106
            "Al-Ma'un",         // 107
            "Al-Kawthar",       // 108
            "Al-Kafirun",       // 109
            "An-Nasr",          // 110
            "Al-Masad",         // 111
            "Al-Ikhlas",        // 112
            "Al-Falaq",         // 113
            "An-Nas"            // 114
        ]
        
        allSurahs.shuffle()

        // Ensure correct answer is included
        var randomChoices = Array(allSurahs.prefix(2))
        randomChoices.append(correctSurah)
        randomChoices.shuffle()

        self.choices = randomChoices
    }
    
    func checkAnswer(_ selectedSurah: String, completion: @escaping (Bool) -> Void) {
        surahSelected = true
        stopAudio()
        
        if selectedSurah == correctAnswer {
            // Correct answer, add coins and load the next verse
            playerAnsweredCorrectly = true
            completion(true)
        } else {
            // Incorrect answer, show correct one
            errorMessage = "Incorrect! The correct answer was \(correctAnswer)"
            playerAnsweredCorrectly = false
            completion(false)
        }
    }
    
    //MARK: - Audio Player
    
    // Audio Player
    @Published var isPlaying = false
    @Published var audioPlayerProgress: Double = 0.0
    
    private var audioPlayer: AVPlayer?
    private var progressTimer: Timer?
    
    func playVerseAudio() {
        guard let verse = verse, let url = URL(string: verse.audio) else {
            errorMessage = "Invalid audio URL"
            return
        }
        
        audioPlayer = AVPlayer(url: url)
        audioPlayer?.play()
        isPlaying = true
        
        // Start the progress timer to update the progress bar
        startProgressTimer()
    }
    
    func stopAudio() {
        audioPlayer?.pause()
        isPlaying = false
        progressTimer?.invalidate()
        audioPlayerProgress = 0.0  // Reset progress
    }
    
    func toggleAudioPlayback() {
        if isPlaying {
            stopAudio()
        } else {
            playVerseAudio()
        }
    }
    
    // Timer for updating the progress bar
    private func startProgressTimer() {
        progressTimer?.invalidate()  // Invalidate any previous timer
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let duration = self.audioPlayer?.currentItem?.duration.seconds,
                  let currentTime = self.audioPlayer?.currentTime().seconds,
                  duration > 0 else {
                return
            }
            self.audioPlayerProgress = currentTime / duration
        }
    }
}


// API https://api.alquran.cloud/v1/ayah/262/ar.alafasy

/*
 {
     "data": {
         "number": 262,
         "audio": "https://cdn.islamic.network/quran/audio/128/ar.alafasy/262.mp3",
         "text": "ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ ۚ لَا تَأْخُذُهُۥ سِنَةٌۭ وَلَا نَوْمٌۭ ۚ لَّهُۥ مَا فِى ٱلسَّمَٰوَٰتِ وَمَا فِى ٱلْأَرْضِ ۗ مَن ذَا ٱلَّذِى يَشْفَعُ عِندَهُۥٓ إِلَّا بِإِذْنِهِۦ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَىْءٍۢ مِّنْ عِلْمِهِۦٓ إِلَّا بِمَا شَآءَ ۚ وَسِعَ كُرْسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلْأَرْضَ ۖ وَلَا يَـُٔودُهُۥ حِفْظُهُمَا ۚ وَهُوَ ٱلْعَلِىُّ ٱلْعَظِيمُ",
         "surah": {
             "number": 2,
             "name": "سُورَةُ البَقَرَةِ",
             "englishName": "Al-Baqara",
             "englishNameTranslation": "The Cow",
             "numberOfAyahs": 286,
             "revelationType": "Medinan"
         },
         "numberInSurah": 255,
         "juz": 3,
         "manzil": 1,
         "page": 42,
         "ruku": 35,
         "hizbQuarter": 17,
         "sajda": false
     }
 }
 */
