import SwiftUI

/// Displays a single register.
private struct SingleRegisterView: View {
    private let backgroundColor = Color.ivory
    private let foregroundColor = Color.blackish

    let index: Int

    var body: some View {
        GeometryReader { proxy in
            let leftMargin = 10.0
            let rightMargin = 20.0
            let width = proxy.size.width - leftMargin - rightMargin

            HStack {
                Spacer(minLength: leftMargin)
                Text("   R\(index)")
                    .frame(width: width * 0.4, height: Style.listLineHeight, alignment: .leading)
                Text(Rcl57.shared.register(atIndex: index))
                    .frame(width: width * 0.6, height: Style.listLineHeight, alignment: .trailing)
                Spacer(minLength: rightMargin)
            }
        }
        .font(Style.listLineFont)
        .listRowBackground(backgroundColor)
        .foregroundColor(foregroundColor)
        .listRowSeparator(.hidden)
    }
}

/// Displays the registers.
struct RegistersView: View {
    // Use a timer to refresh the registers in case they have changed. This is necessary because
    // those belong to the emulator and are not directly observed by SwifUI.
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    @State private var refreshID: Int64 = 0

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(0..<Rcl57.shared.registerCount, id: \.self) {
                    SingleRegisterView(index: $0)
                }
                .id(refreshID)
            }
            .background(Color.ivory)
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, Style.listLineHeight)
        }
        .onReceive(timer) { _ in
            refreshID += 1
        }
    }
}

struct RegistersView_Previews: PreviewProvider {
    static var previews: some View {
        RegistersView()
    }
}
