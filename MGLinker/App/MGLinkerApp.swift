import SwiftUI

@main
struct MGLinkerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "car.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            Text("MG Linker")
                .font(.title)
            Text("iOS版本开发中")
                .foregroundColor(.gray)
        }
        .padding()
    }
}