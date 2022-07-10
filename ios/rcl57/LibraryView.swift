import SwiftUI

struct LibraryView: View {
    let lib: Lib57
    let change: Change

    var body: some View {
        if lib.programs.isEmpty {
            Text("Empty")
        } else {
            ForEach(lib.programs, id: \.self) { program in
                Button(program.getName()) {
                    withAnimation {
                        change.program = program
                    }
                }
            }
        }
    }
}
