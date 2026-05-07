import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HiitSetupView()
                .tabItem {
                    Label("HiiT", systemImage: "bolt.fill")
                }

            StrengthSetupView()
                .tabItem {
                    Label("Strength", systemImage: "dumbbell.fill")
                }

            CardioSetupView()
                .tabItem {
                    Label("Cardio", systemImage: "figure.run")
                }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
}
