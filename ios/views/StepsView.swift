import SwiftUI

/// Displays a single step.
private struct SingleStepView: View {
    // Note: currently we don't differentiate between active and inactive steps.
    private let activeBackgroundColor = Color.ivory
    private let inactiveBackgroundColor = Color.ivory
    private let foregroundColor = Color.blackish
    private let inactiveForegroundColor = Color.blackish

    /// The index of the step in the program.
    let index: Int

    var body: some View {
        let step = Rcl57.shared.step(atIndex: index, isAlpha: true)
        let active = index <= Rcl57.shared.stepsLastIndex

        GeometryReader { proxy in
            let leftMargin = 10.0
            let rightMargin = 20.0
            let width = proxy.size.width - leftMargin - rightMargin

            HStack {
                Spacer(minLength: leftMargin)
                Text(String(format: "   %02d", index))
                    .frame(width: width * 0.4, height: Style.listLineHeight, alignment: .leading)
                Text(step)
                    .frame(width: width * 0.6, height: Style.listLineHeight, alignment: .trailing)
                Spacer(minLength: rightMargin)
            }
        }
        .font(Style.listLineFont)
        .foregroundColor(active ? foregroundColor: inactiveForegroundColor)
        .listRowSeparator(.hidden)
        .listRowBackground(active ? activeBackgroundColor : inactiveBackgroundColor)
    }
}

/// Displays the steps of the program in memory.
struct StepsView: View {
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(0..<Rcl57.shared.stepCount, id: \.self) {
                    SingleStepView(index: $0)
                }
            }
            .background(Color.ivory)
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, Style.listLineHeight)
        }
    }
}

struct StepsView_Previews: PreviewProvider {
    static var previews: some View {
        StepsView()
    }
}
