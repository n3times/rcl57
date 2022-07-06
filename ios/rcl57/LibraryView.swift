import SwiftUI

struct LibraryView: View {
    let lib: Lib57

    @EnvironmentObject private var change: Change

    var body: some View {
        List {
            ForEach(lib.programs, id: \.self) { program in
                Button(program.getName()) {
                    withAnimation {
                        change.program = program
                    }
                }
                .listRowBackground(Style.ivory)
                .foregroundColor(Style.blackish)
            }
        }
        .listStyle(PlainListStyle())
    }
}
