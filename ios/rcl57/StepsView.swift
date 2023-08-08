import SwiftUI

/// Displays a single step.
private struct SingleStepView: View {
    private let activeBackgroundColor = Color.ivory
    private let inactiveBackgroundColor = Color.ivory
    private let foregroundColor = Color.blackish
    private let inactiveForegroundColor = Color.blackish

    /// The index of the step into the program.
    let index: Int

    var body: some View {
        let op = Rcl57.shared.stepOp(atIndex: index, isAlpha: true)
        let active = index <= Rcl57.shared.stepsLastIndex

        HStack {
            Spacer(minLength: 10)
            Text(String(format: "   %02d", index))
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .leading)
            Text(op)
                .frame(maxWidth: .infinity, idealHeight:10, alignment: .trailing)
            Spacer(minLength: 20)
        }
        .font(Style.listLineFont)
        .listRowBackground(active ? activeBackgroundColor : inactiveBackgroundColor)
        .foregroundColor(active ? foregroundColor: inactiveForegroundColor)
        .listRowSeparator(.hidden)
    }
}

/// Displays the 50 steps of the program in memory.
struct StepsView: View {
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(0...49, id: \.self) {
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
