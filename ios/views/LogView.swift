import SwiftUI

/// Displays the operations keyed in by the user, and the results.
struct LogView: View {
    @EnvironmentObject private var appState: AppState

    @State private var isPresentingClear = false

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                NavigationBar(left: Style.leftArrow,
                              title: "Log",
                              right: nil,
                              leftAction: { withAnimation { appState.appLocation = .calc } },
                              rightAction: nil)
                .background(Color.blackish)

                if Log57.shared.entryCount == 0 {
                    Text("Log is empty")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .background(Color.ivory)
                        .foregroundColor(.blackish)
                } else {
                    LogContentView()
                        .background(Color.ivory)
                }

                HStack(spacing: 0) {
                    Spacer()
                    Button(action: {
                        isPresentingClear = true
                    }) {
                        Text("CLEAR")
                            .font(Style.toolbarFont)
                            .frame(width: proxy.size.width * 2 / 3, height: Style.toolbarHeight)
                            .contentShape(Rectangle())
                    }
                    .disabled(Log57.shared.entryCount == 0)
                    .buttonStyle(.plain)
                    .confirmationDialog("Clear?", isPresented: $isPresentingClear) {
                        Button("Clear Log", role: .destructive) {
                            Log57.shared.clearEntries()
                        }
                    }
                    Spacer()
                }
                .background(Color.blackish)
                .foregroundColor(.ivory)
            }
        }
    }

    struct LogView_Previews: PreviewProvider {
        static var previews: some View {
            LogView()
        }
    }
}
