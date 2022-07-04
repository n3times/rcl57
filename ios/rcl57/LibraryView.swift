import SwiftUI

struct LibraryView: View {
    let lib: Lib57

    @EnvironmentObject private var change: Change

    var body: some View {
        List {
            ForEach(lib.programs, id: \.self) { program in
                let programView = ProgramView(program: program)
                NavigationLink(destination: programView) {
                    Text(program.getName())
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(lib.name)
        .navigationBarItems(
            trailing:
                Button(action: {
                    withAnimation {
                        change.currentView = .calc
                    }
                }) {
                    Text(Style.circle)
                        .frame(width: 70, height: Style.headerHeight, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .font(Style.directionsFont)
        )
    }
}
