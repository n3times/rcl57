import SwiftUI

struct FullLibraryView: View {
    @EnvironmentObject var change: Change

    var body: some View {
        ZStack {
            if (change.program == nil && !change.createProgram) {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    VStack(spacing: 0) {
                        MenuBarView(change: change,
                                    left: nil,
                                    title: "Library",
                                    right: Style.downArrow,
                                    width: width,
                                    leftAction: {},
                                    rightAction: { withAnimation {change.currentView = .calc} })
                            .frame(width: width)

                        List {
                            Section(header: Text("User Programs")) {
                                LibraryView(lib: Lib57.userLib, change: change)
                            }
                            Section(header: Text("Examples")) {
                                LibraryView(lib: Lib57.examplesLib, change: change)
                            }
                        }

                        HStack(spacing: 0) {
                            Spacer()
                                .frame(width: width / 6, height: Style.footerHeight)
                            Button("Create Program") {
                                withAnimation {
                                    change.createProgram = true
                                }
                            }
                            .font(Style.footerFont)
                            .frame(width: width * 2 / 3, height: Style.footerHeight)
                            .buttonStyle(.plain)
                            Spacer()
                                .frame(width: width / 6, height: Style.footerHeight)
                        }
                        .background(Style.blackish)
                        .foregroundColor(Style.ivory)
                    }
                }
                .transition(.move(edge: .leading))
            }

            if (change.program != nil) {
                FullProgramView(program: change.program!)
                    .environmentObject(change)
                    .transition(.move(edge: .trailing))
            }
            if (change.createProgram) {
                CreateProgramView()
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
