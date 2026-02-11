import Foundation
import GRDB

final class AppDatabase {
    let queue: DatabaseQueue

    init() {
        guard let databaseURL = Bundle.main.url(
            forResource: "speech",
            withExtension: "sqlite"
        ) else {
            fatalError("Missing speech.sqlite in app bundle")
        }

        var configuration = Configuration()
        configuration.readonly = true

        do {
            queue = try DatabaseQueue(
                path: databaseURL.path,
                configuration: configuration
            )
        } catch {
            fatalError("Failed to open bundled database: \(error)")
        }
    }

    func fetchTrackData(filename: String) -> Data? {
        do {
            let data = try queue.read { db -> Data? in
                let row = try Row.fetchOne(
                    db,
                    sql: "SELECT data FROM tracks WHERE filename = ? LIMIT 1",
                    arguments: [filename]
                )
                return row?["data"]
            }
            return data
        } catch {
            print("Fetch failed: \(error)")
            return nil
        }
    }
}
