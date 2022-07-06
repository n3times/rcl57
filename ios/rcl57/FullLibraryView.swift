import SwiftUI

struct FullLibraryView: View {
    @EnvironmentObject var change: Change

    var body: some View {
        ZStack {
            if (change.program == nil) {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    VStack(spacing: 0) {
                        // Menu.
                        HStack(spacing: 0) {
                            Spacer()
                                .frame(width: width / 6, height: Style.headerHeight)
                            Text("Library")
                                .frame(width: width * 2 / 3, height: Style.headerHeight)
                                .font(Style.titleFont)
                            Button(action: {
                                withAnimation {
                                    change.currentView = .calc
                                }
                            }) {
                                Text(Style.square)
                                    .frame(width: width / 6, height: Style.headerHeight)
                                    .font(Style.directionsFont)
                                    .contentShape(Rectangle())
                            }
                        }
                        .background(Style.blackish)
                        .foregroundColor(Style.ivory)

                        LibraryView(lib: Lib57.examplesLib)
                            .background(Style.ivory)
                    }
                }
                .transition(.move(edge: .leading))
            }

            if (change.program != nil) {
                FullProgramView(program: change.program!)
                    .environmentObject(change)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}

struct FullLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        FullLibraryView()
    }
}
