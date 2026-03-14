import SwiftUI

struct TurnTimerView: View {
    let progress: Double // 0.0 to 1.0
    let isUrgent: Bool   // last 10 seconds

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))

                // Fill bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(isUrgent ? Color.red : Color.accentColor)
                    .frame(width: geo.size.width * progress)
                    .opacity(isUrgent ? urgentOpacity : 1.0)
            }
        }
        .frame(height: 6)
    }

    private var urgentOpacity: Double {
        // Pulse effect via the progress value itself
        let pulse = sin(progress * .pi * 20) * 0.3 + 0.7
        return pulse
    }
}

#Preview {
    VStack(spacing: 20) {
        TurnTimerView(progress: 0.7, isUrgent: false)
        TurnTimerView(progress: 0.2, isUrgent: true)
    }
    .padding()
}
