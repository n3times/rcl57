import SwiftUI

/// Displays a single register.
private struct SingleRegisterView: View {
    let index: Int

    private let backgroundColor = Color.ivory
    private let foregroundColor = Color.blackish

    var body: some View {
        HStack {
            Spacer(minLength: 10)
            Text("   R\(index)")
                .frame(maxWidth: 100, idealHeight:10, alignment: .leading)
            Text(Rcl57.shared.register(atIndex: index))
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .trailing)
            Spacer(minLength: 20)
        }
        .font(Style.listLineFont)
        .listRowBackground(backgroundColor)
        .foregroundColor(foregroundColor)
    }
}

/// Displays the 8 registers.
struct RegistersView: View {
    @EnvironmentObject private var change: Change

    // Use a timer to refresh the registers in case they have changed. This is necessary because
    // those belong to the emulator and are not directly observed by SwifUI.
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    @State private var refreshCounter: Int64 = 0

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(0...7, id: \.self) {
                    SingleRegisterView(index: $0)
                        .listRowSeparator(.hidden)
                }
                .id(refreshCounter)
            }
            .background(Color.ivory)
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, Style.listLineHeight)
        }
        .onReceive(timer) { _ in
            refreshCounter += 1
        }
    }
}

struct RegistersView_Previews: PreviewProvider {
    static var previews: some View {
        RegistersView()
    }
}
