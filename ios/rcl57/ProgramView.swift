import SwiftUI

private struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ActivityViewController>) {
        // Nothing to update.
    }
}

/**
 * Let's the user delete, edit and share the program.
 */
private struct Footer: View {
    @EnvironmentObject var change: Change

    @State var isPresentingDelete = false
    @State var isPresentingShare = false

    let program: Prog57
    let width: Double

    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                isPresentingShare = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(Style.directionsFont)
                    .offset(x: 15)
                    .frame(width: width / 5, height: Style.footerHeight, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .sheet(isPresented: $isPresentingShare) {
                ActivityViewController(activityItems: [program.url!])
            }

            Button(action: {
                program.loadStepsIntoMemory()
                program.loadRegistersIntoMemory()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    change.setLoadedProgram(program: program)
                }
                withAnimation {
                    change.currentViewType = .calc
                }
            }) {
                let loadButtonText = program == change.loadedProgram ? "RELOAD" : "LOAD"
                Text(loadButtonText)
                    .font(Style.footerFont)
                    .frame(width: width * 3 / 5, height: Style.footerHeight, alignment: .center)
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
            }

            if program.isReadOnly {
                Spacer()
                    .frame(width: width / 5, height: Style.footerHeight)
            } else {
                Menu {
                    Button(action: {
                        isPresentingDelete = true
                    }) {
                        Text("Delete")
                    }
                    Button(action: {
                        change.isPreviewInEditProgram = false
                        withAnimation {
                            change.isEditInProgramView = true
                        }
                    }) {
                        Text("Edit")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(Style.directionsFont)
                        .frame(width: width / 5, height: Style.footerHeight, alignment: .trailing)
                        .offset(x: -15)
                        .contentShape(Rectangle())
                }
                .frame(width: width / 5, height: Style.footerHeight, alignment: .trailing)
                .offset(x: -15)
                .contentShape(Rectangle())
                .confirmationDialog("Delete?", isPresented: $isPresentingDelete) {
                    Button("Delete \(program.name)", role: .destructive) {
                        _ = Lib57.userLib.deleteProgram(program)
                        if program == change.loadedProgram {
                            change.loadedProgram = nil
                        }
                        change.isUserLibExpanded = true
                        withAnimation {
                            change.programView = nil
                        }
                    }
                }
            }
        }
    }
}

/**
 * Displays the name and description of a program. Lets the user take different actions on the
 * program.
 */
struct ProgramView: View {
    @EnvironmentObject var change: Change

    let program: Prog57

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            VStack(spacing: 0) {
                NavigationBar(left: Style.leftArrow,
                              title: program.name,
                              right: Style.downArrow,
                              leftAction: { withAnimation { change.programView = nil } },
                              rightAction: { withAnimation { change.currentViewType = .calc } })
                .background(Color.deepBlue)

                if program.help.isEmpty {
                    Text("No description available")
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .center)
                        .background(Color.ivory)
                        .foregroundColor(.blackish)
                } else {
                    HelpView(helpString: program.help)
                }

                Footer(program: program, width: width)
                    .frame(maxHeight: Style.footerHeight)
            }
            .background(Color.deepBlue)
            .foregroundColor(.ivory)

            if change.isEditInProgramView {
                ProgramEditView(program: program)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
    }
}

struct ProgramView_Previews: PreviewProvider {
    @EnvironmentObject var change: Change

    static var previews: some View {
        ProgramView(program: Prog57(name: "", description: ""))
    }
}
