import SwiftUI

/** A list of LineView's. */
struct FullLrnView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false

    let rcl57 : Rcl57

    var body: some View {
        return GeometryReader { geometry in
            let width = geometry.size.width
            VStack(spacing: 0) {
                // Menu.
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: width / 6, height: Style.headerHeight)
                    Text("Program")
                        .frame(width: width * 2 / 3, height: Style.headerHeight)
                        .font(Style.titleFont)
                    // Right button.
                    Button(action: {
                        withAnimation {
                            change.isFullProgram.toggle()
                        }
                    }) {
                        Text(Style.rightArrow)
                            .frame(width: width / 6, height: Style.headerHeight)
                            .font(Style.directionsFont)
                            .contentShape(Rectangle())
                    }
                }
                .background(Style.blackish)
                .foregroundColor(Style.ivory)

                // Program.
                LrnView(rcl57: rcl57, isMiniView: false)
                    .background(Style.ivory)
                    .environmentObject(change)

                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: width / 6, height: Style.footerHeight)
                    Button("Clear") {  // Left arrow.
                        isPresentingConfirm = true
                    }
                    .font(Style.titleFont)
                    .frame(width: width * 2 / 3, height: Style.footerHeight)
                    .disabled(rcl57.getProgramLastIndex() == -1)
                    .buttonStyle(.plain)
                    .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                        Button("Clear Program", role: .destructive) {
                            rcl57.clearProgram()
                            change.forceUpdate()
                        }
                    }
                    Spacer()
                        .frame(width: width / 6, height: Style.footerHeight)
                }
                .background(Style.blackish)
                .foregroundColor(Style.ivory)
            }
        }
    }
}

struct FullLrnView_Previews: PreviewProvider {
    static var previews: some View {
        FullLrnView(rcl57: Rcl57())
    }
}
