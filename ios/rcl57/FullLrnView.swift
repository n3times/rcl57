import SwiftUI

/** A list of LineView's. */
struct FullLrnView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false

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
                LrnView(isMiniView: false)
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
                    .disabled(Rcl57.shared.getProgramLastIndex() == -1)
                    .buttonStyle(.plain)
                    .confirmationDialog("Are you sure?", isPresented: $isPresentingConfirm) {
                        Button("Clear Program", role: .destructive) {
                            Rcl57.shared.clearProgram()
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
        FullLrnView()
    }
}
