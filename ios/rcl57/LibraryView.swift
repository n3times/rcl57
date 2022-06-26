import SwiftUI

struct LibraryView: View {
    @Binding var showBack: Bool
    let lib: Lib57

    var body: some View {
        List {
            ForEach(lib.programs, id: \.self) { program in
                let programView = ProgramView(showBack: $showBack, program: program)
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
                        showBack.toggle()
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
