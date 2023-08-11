import SwiftUI

/// Displays a single register.
private struct SingleRegisterView: View {
    @EnvironmentObject private var emulatorState: EmulatorState

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
                Text(emulatorState.registers[index])
                    .frame(width: width * 0.6, height: Style.listLineHeight, alignment: .trailing)
                Spacer(minLength: rightMargin)
            }
            .offset(y: -4)
        }
        .font(Style.listLineFont)
        .listRowBackground(backgroundColor)
        .foregroundColor(foregroundColor)
        .listRowSeparator(.hidden)
    }
}

/// Displays the registers.
struct RegistersView: View {
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(0..<Rcl57.shared.registerCount, id: \.self) {
                    SingleRegisterView(index: $0)
                }
            }
            .background(Color.ivory)
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, Style.listLineHeight)
        }
    }
}

struct RegistersView_Previews: PreviewProvider {
    static var previews: some View {
        RegistersView()
    }
}
