import SwiftUI

private struct LibraryNode: Identifiable {
    let id = UUID()
    let name: String
    var children: [LibraryNode] = []
    var program: Prog57?

    init(program: Prog57) {
        self.name = program.getName()
        self.program = program
    }

    init(library: Lib57) {
        self.name = library.name
        let programs = library.programs
        if (programs.count > 0) {
            children = []
            for program in programs {
                children.append(LibraryNode(program: program))
            }
        }
    }

    static let examplesLib = LibraryNode(library: Lib57.examplesLib)
    var userLib: LibraryNode {
        LibraryNode(library: Lib57.examplesLib)
    }
}

struct LibraryView: View {
    @EnvironmentObject var change: Change

    var body: some View {
        ZStack {
            if change.program == nil {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    VStack(spacing: 0) {
                        MenuBarView(change: change,
                                    left: nil,
                                    title: "Library",
                                    right: Style.downArrow,
                                    width: width,
                                    background: Style.deepBlue,
                                    leftAction: {},
                                    rightAction: { withAnimation {change.currentView = .calc} })
                        .frame(width: width)

                        let userLib = LibraryNode(library: Lib57.userLib)
                        let items: [LibraryNode] = [.examplesLib, userLib]

                        List {
                            DisclosureGroup(isExpanded: $change.examplesLibExpanded) {
                                ForEach(items[0].children) { item in
                                    Button(item.name) {
                                        withAnimation {
                                            change.program = item.program
                                        }
                                    }
                                }
                            } label: {
                                Label(items[0].name, systemImage: "folder")
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            change.examplesLibExpanded.toggle()
                                        }
                                    }
                                    .foregroundColor(Color.black)
                            }

                            DisclosureGroup(isExpanded: $change.userLibExpanded) {
                                if items[1].children.count == 0 {

                                } else {
                                    ForEach(items[1].children) { item in
                                        Button(item.name) {
                                            withAnimation {
                                                change.program = item.program
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Label(items[1].name, systemImage: "folder")
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            change.userLibExpanded.toggle()
                                        }
                                    }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .background(Color.white)
                .transition(.move(edge: .leading))
            }

            if (change.program != nil) {
                ProgramView(program: change.program!)
                    .environmentObject(change)
                    .transition(.move(edge: .trailing))
            }
        }
        .foregroundColor(Color.black)
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
