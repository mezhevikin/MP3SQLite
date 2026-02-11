# MP3SQLite Benchmark

This project explores the performance of loading audio files in an iOS app. It answers the question: Is it faster to read MP3 files directly from the disk, or to read them from a SQLite database?

## What It Does

The app benchmarks two different methods for loading a collection of MP3 audio files:

1.  **Reading from Files**: The app gets a list of MP3 files stored in the application bundle and reads them one by one using their file paths. This is the conventional approach.

2.  **Reading from SQLite**: The same MP3 files are also stored as `BLOB` data inside a single SQLite database file. The app queries the database to retrieve the data for each MP3.

## The Benchmark Process

When you tap the "Run Benchmark" button, the app does the following:

1.  It takes a list of about 100 MP3 files and shuffles them randomly.
2.  It measures the total time it takes to load all the files using the **SQLite** method. For each file, it fetches the data from the database and prepares an audio player (`AVAudioPlayer`).
3.  It then measures the total time it takes to load the same files using the **direct file** method. For each file, it finds the file on disk and prepares an audio player.
4.  Finally, it displays the time taken for both methods and calculates the percentage difference in performance.

## The Result

In practice, the performance is very similar for both methods. The difference is typically small, often around 1-2%, and sometimes there is no significant difference at all. This suggests that storing assets like MP3s in a SQLite database can be a viable alternative to storing them as individual files, without a major performance penalty.