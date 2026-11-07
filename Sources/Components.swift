import SwiftUI
import UIKit

// MARK: - Icon cache

/// Downloads character icons once and keeps them on disk, so they work offline afterwards.
actor ImageStore {
    static let shared = ImageStore()

    private var memory: [String: UIImage] = [:]
    private var failed: Set<String> = []

    private let directory: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("icons", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private func fileURL(for url: URL) -> URL {
        let safe = url.absoluteString
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "/", with: "_")
        return directory.appendingPathComponent(safe)
    }

    func image(for urls: [URL]) async -> UIImage? {
        for url in urls {
            if let img = await load(url) { return img }
        }
        return nil
    }

    private func load(_ url: URL) async -> UIImage? {
        let key = url.absoluteString
        if let img = memory[key] { return img }
        if failed.contains(key) { return nil }

        let file = fileURL(for: url)
        if let data = try? Data(contentsOf: file), let img = UIImage(data: data) {
            memory[key] = img
            return img
        }

        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 20
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200,
                  let img = UIImage(data: data) else {
                failed.insert(key)
                return nil
            }
            try? data.write(to: file, options: .atomic)
            memory[key] = img
            return img
        } catch {
            // Network errors aren't remembered, so it retries next time.
            return nil
        }
    }

    func clearDiskCache() {
        memory.removeAll()
        failed.removeAll()
        try? FileManager.default.removeItem(at: directory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
}

// MARK: - Character icon

struct CharacterIcon: View {
    let character: CharacterEntry
    var size: CGFloat = 40
    var dimmed: Bool = false

    @State private var image: UIImage?

    private var ringColor: Color { GameData.color(for: character.element) }

    private var initials: String {
        let parts = character.name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: character.rarity >= 5
                            ? [Color(red: 0.62, green: 0.42, blue: 0.22), Color(red: 0.86, green: 0.62, blue: 0.32)]
                            : [Color(red: 0.36, green: 0.30, blue: 0.55), Color(red: 0.56, green: 0.44, blue: 0.75)],
                        startPoint: .top, endPoint: .bottom)
                )
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Text(initials)
                    .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
        .overlay(Circle().stroke(ringColor, lineWidth: max(1.5, size * 0.05)))
        .saturation(dimmed ? 0 : 1)
        .opacity(dimmed ? 0.55 : 1)
        .task(id: character.iconName) {
            let urls = character.iconURLs
            guard !urls.isEmpty else { image = nil; return }
            image = await ImageStore.shared.image(for: urls)
        }
    }
}

// MARK: - Typed number entry

/// A number field you can type into directly. Keeps a text buffer so partial input
/// (like an empty field while retyping) doesn't fight the user, and writes through on every change.
struct IntField: View {
    let title: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 0...Int.max
    var width: CGFloat = 110

    @State private var text: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", text: $text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.body.monospacedDigit())
                .frame(width: width)
                .focused($focused)
                .onChange(of: text) { newText in
                    let digits = newText.filter { $0.isNumber }
                    if digits != newText { text = digits; return }
                    if let v = Int(digits) {
                        let clamped = min(max(v, range.lowerBound), range.upperBound)
                        if clamped != value { value = clamped }
                    }
                }
                .onChange(of: focused) { isFocused in
                    // When the user leaves the field, show the clamped value.
                    if !isFocused { text = String(value) }
                }
        }
        .onAppear { text = String(value) }
        .onChange(of: value) { newValue in
            if !focused { text = String(newValue) }
        }
    }
}

/// Adds a "Done" button above the number pad (which has no return key).
struct KeyboardDoneToolbar: ViewModifier {
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
    }
}

extension View {
    func keyboardDoneButton() -> some View { modifier(KeyboardDoneToolbar()) }
}
