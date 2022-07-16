import SwiftUI

struct SingleLibraryView: View {
    let lib: Lib57
    let change: Change

    var body: some View {
        if lib.programs.isEmpty {
            Button("Empty") {
            }
            .disabled(true)
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
