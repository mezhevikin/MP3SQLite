import Foundation
import AVFoundation
import GRDB

class Benchmark {
    private let db = AppDatabase()
    private let bundle: Bundle

    init() {
        guard let bundleURL = Bundle.main.url(forResource: "speech", withExtension: "bundle"),
              let bundle = Bundle(url: bundleURL) else {
            fatalError("speech.bundle not found")
        }
        self.bundle = bundle
        
        warmUpAudioPlayer()
    }
    
    func run() -> BenchmarkResult {
        let filenames = loadFilenames()
        let shuffled = filenames.shuffled()
        let sqliteTime = measureSQLite(filenames: shuffled)
        let urlTime = measureURL(filenames: shuffled)
        let percent = ((sqliteTime - urlTime) / max(urlTime, 0.000_001)) * 100

        return BenchmarkResult(
            sqliteTime: sqliteTime,
            urlTime: urlTime,
            percent: percent
        )
    }
    
    private func loadFilenames() -> [String] {
        let urls = bundle.urls(forResourcesWithExtension: "mp3", subdirectory: nil) ?? []
        return urls.map { $0.lastPathComponent }
    }

    private func warmUpAudioPlayer() {
        guard let url = bundle.url(
            forResource: "0a0bb4f0c171ed60f66ce2f9915bd441.mp3",
            withExtension: nil
        ) else {
            return
        }
        if let player = try? AVAudioPlayer(contentsOf: url) {
            player.prepareToPlay()
        }
    }

    private func measureSQLite(filenames: [String]) -> Double {
        let startTime = Date()
        for filename in filenames {
            guard let data = db.fetchTrackData(filename: filename) else {
                continue
            }
            if let player = try? AVAudioPlayer(data: data) {
                player.prepareToPlay()
                _ = player
            }
        }
        return Date().timeIntervalSince(startTime)
    }

    private func measureURL(filenames: [String]) -> Double {
        let startTime = Date()
        for filename in filenames {
            guard let url = bundle.url(forResource: filename, withExtension: nil) else {
                continue
            }
            if let player = try? AVAudioPlayer(contentsOf: url) {
                player.prepareToPlay()
                _ = player
            }
        }
        return Date().timeIntervalSince(startTime)
    }
}

struct BenchmarkResult {
    let sqliteTime: Double
    let urlTime: Double
    let percent: Double

    var sqliteText: String {
        "Benchmark sqlite: \(sqliteTime) s"
    }

    var urlText: String {
        "Benchmark url: \(urlTime) s"
    }

    var differenceText: String {
        String(format: "Difference: %.2f%%", percent)
    }
}
