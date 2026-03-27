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
        VStack(spacing: 20) {
            Image(systemName: "car.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("MG Linker")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("上汽名爵/荣威车辆监控")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("iOS版本 v1.0")
                .font(.caption)
                .padding(.top, 10)
        }
        .padding()
    }
}