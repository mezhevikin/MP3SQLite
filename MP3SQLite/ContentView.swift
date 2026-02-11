import SwiftUI

struct ContentView: View {
    @State private var result: BenchmarkResult?
    @State private var isRunning = false

    var body: some View {
        VStack(spacing: 20) {
            Button("Run Benchmark") {
                guard !isRunning else {
                    return
                }
                isRunning = true
                result = nil
                Task.detached(priority: .userInitiated) {
                    let result = await Benchmark().run()
                    await MainActor.run {
                        self.result = result
                        self.isRunning = false
                    }
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .frame(maxWidth: .infinity)

            if isRunning {
                ProgressView()
                    .padding(.top, 12)
            }

            if let result {
                Text(result.sqliteText)
                Text(result.urlText)
                Text(result.differenceText)
            }
            Spacer()
        }
        .padding()
    }
}
