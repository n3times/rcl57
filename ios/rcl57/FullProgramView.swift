import SwiftUI

struct FullProgramView: View {
    @EnvironmentObject var change: Change
    @State private var isPresentingConfirm: Bool = false
    let program: Prog57

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                VStack(spacing: 0) {
                    // Menu.
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation {
                                change.program = nil
                            }
                        }) {
                            Text(Style.leftArrow)
                                .frame(width: width / 6, height: Style.headerHeight)
                                .font(Style.directionsFont)
                                .contentShape(Rectangle())
                        }
                        Text(program.getName())
                            .frame(width: width * 2 / 3, height: Style.headerHeight)
                            .font(Style.titleFont)
                        Button(action: {
                            withAnimation {
                                change.currentView = .calc
                            }
                        }) {
                            Text(Style.downArrow)
                                .frame(width: width / 6, height: Style.headerHeight)
                                .font(Style.directionsFont)
                                .contentShape(Rectangle())
                        }
                    }
                    .background(Style.deepBlue)
                    .foregroundColor(Style.ivory)

                    ProgramView(program: program)
                        .background(Style.ivory)
                }
            }
            .transition(.move(edge: .leading))
        }
    }
}

struct FullProgramView_Previews: PreviewProvider {
    static var previews: some View {
        FullLibraryView()
    }
}
