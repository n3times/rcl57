import SwiftUI

struct LibraryView: View {
    let userLib = Lib57.userLib
    let examplesLib = Lib57.examplesLib

    @EnvironmentObject private var change: Change

    var body: some View {
        List {
            Section(header: Text("User Programs")) {
                if Lib57.userLib.programs.isEmpty {
                    Button("Empty") {
                        withAnimation {
                            change.createProgram = true
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(true)
                } else {
                    ForEach(userLib.programs, id: \.self) { program in
                        Button(program.getName()) {
                            withAnimation {
                                change.program = program
                            }
                        }
                    }
                }
            }
            Section(header: Text("Examples")) {
                ForEach(examplesLib.programs, id: \.self) { program in
                    Button(program.getName()) {
                        withAnimation {
                            change.program = program
                        }
                    }
                }
            }
        }
    }
}
