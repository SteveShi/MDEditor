# MDEditor

MDEditor is a Markdown editor component for macOS and iOS built on TextKit 2, designed to provide a Ulysses-style "What You See Is Mean" editing experience.

## Features

- **TextKit 2 Architecture**: Leverages Apple's latest text engine for high performance and deep customization.
- **Real-time Highlighting**: Supports full Markdown syntax highlighting including bold, italic, code blocks, links, and more.
- **Image Preview**: In-editor rendering for both local and remote images.
- **Typewriter Mode**: Keeps the cursor centered on the screen for a focused writing experience.
- **Modular Design**: Easy to integrate into any SwiftUI or AppKit based Swift project.

## Installation

### Swift Package Manager

Add the following dependency to your project:

```swift
.package(url: "https://github.com/SteveShi/MDEditor.git", from: "1.8.0")
```

## Quick Start

```swift
import SwiftUI
import MDEditor

struct EditorScreen: View {
    @State private var text: String = "# Hello\n\nStart writing…"
    @StateObject private var proxy = MDEditorProxy()
    @State private var configuration: EditorConfiguration = .default

    var body: some View {
        MDEditorView(text: $text, configuration: configuration, proxy: proxy)
            .onAppear {
                proxy.onTextChange = { newText in
                    // debounce + save
                }
                proxy.onSelectionChange = { range, fullText in
                    // update context-sensitive UI
                }
            }
    }
}
```

## API Reference

All editor interactions go through **`MDEditorProxy`** (`ObservableObject`). Attach it to a `MDEditorView` and call its public methods from your host. Methods are no-ops when the view isn't yet mounted.

### Observation

| Property | Type | Description |
| --- | --- | --- |
| `onSelectionChange` | `((NSRange, String) -> Void)?` | Fires on every selection or caret movement (main thread). `range.length == 0` means a pure caret. `text` is the reconstructed Markdown source. |
| `onTextChange` | `((String) -> Void)?` | Fires on every text mutation (main thread). Use for debounced autosave, stats refresh, or AI streaming hooks. |

### Basic Edits

| Method | Purpose |
| --- | --- |
| `insert(_ text: String)` | Insert text at the current selection. |
| `wrapSelection(prefix:suffix:)` | Wrap the current selection with `prefix` / `suffix` (e.g. `**` / `**`). |
| `getSelectedText() -> String?` | Return the currently selected substring. |
| `getSelectedRange() -> NSRange` | Return the current selection range. |
| `getFullText() -> String` | Return the full document as Markdown source (image attachments reconstructed back to `![]()`). |
| `replace(range:with:)` | Atomic replacement of an arbitrary range — preserves the undo stack and delegate callbacks. |
| `setSelectedRange(_ range: NSRange)` | Move the caret or selection. Clamped to the document length. |

### Current-Line Helpers

| Method | Purpose |
| --- | --- |
| `getCurrentLineRange() -> NSRange` | `NSRange` of the line containing the caret (includes the trailing newline if present). |
| `getCurrentLineText() -> String` | Text of the line containing the caret (includes the trailing newline if present). |
| `replaceCurrentLine(with replacement: String)` | Atomic replacement of the current line — typical use is Ulysses-style block-prefix swapping (`# ` → `## `, list to quote, …). |

### Undo / Redo

| Member | Purpose |
| --- | --- |
| `undo()` | Trigger the editor's undo manager. |
| `redo()` | Trigger the editor's redo manager. |
| `canUndo: Bool` | Whether undo is currently available — useful for toolbar enablement. |
| `canRedo: Bool` | Whether redo is currently available. |

### Focus

| Method | Purpose |
| --- | --- |
| `focus()` | Make the editor the window's first responder. |
| `resignFocus()` | Resign first responder if currently focused. |

### Scrolling

| Method | Purpose |
| --- | --- |
| `scrollRangeToVisible(_ range: NSRange)` | Scroll so `range` becomes visible (used by outline jumps, AI follow-cursor, etc.). |
| `scrollToTop()` | Scroll to the document head. |
| `scrollToBottom()` | Scroll to the document tail. |

### Caret Geometry

| Method | Purpose |
| --- | --- |
| `caretFrameInWindow() -> CGRect?` | Caret rect in the editor's window coordinate space — anchor floating popovers, inline completions, mention pickers, etc. Returns `nil` when the view is not mounted or no caret is positionable. |

### Selection Helpers

| Method | Purpose |
| --- | --- |
| `selectAll()` | Select the entire document. |
| `selectLine()` | Select the line under the caret (includes the trailing newline if present). |
| `selectParagraph()` | Select the paragraph under the caret (paragraphs delimited by blank lines). |

### Stats Snapshot

`stats() -> EditorStats` returns a snapshot for status-bar style UI:

```swift
public struct EditorStats: Equatable {
    public let characterCount: Int   // Swift Character (grapheme cluster) count
    public let wordCount: Int        // Whitespace-separated non-empty tokens
    public let lineCount: Int        // `\n`-delimited lines; 0 for empty text
}
```

Pair it with `onTextChange` to keep a `@Published` value live without rescanning the document yourself:

```swift
proxy.onTextChange = { [weak self] _ in
    self?.stats = self?.proxy.stats() ?? .init(characterCount: 0, wordCount: 0, lineCount: 0)
}
```

### Attachments & Export

| Method | Purpose |
| --- | --- |
| `insertImage(_ image: NSImage, altText: String = "")` | Insert an image at the caret. Persistence is delegated to `EditorConfiguration.imageSaver`; the editor writes `![alt](returned-url)` for you. No-op when no `imageSaver` is configured. |
| `exportAttributedString() -> NSAttributedString` | Snapshot of the current `NSTextStorage` (with syntax highlighting attributes) — usable for RTF / PDF export pipelines. |

### Indent / Outdent

| Method | Purpose |
| --- | --- |
| `indentSelection()` | Add one Tab in front of every selected line (or the caret line when nothing is selected). |
| `outdentSelection()` | Remove one leading Tab, or 2 / 4 leading spaces, from every selected line. |

### Find & Replace

| Method | Purpose |
| --- | --- |
| `findNext(text:)` | Find the next case-insensitive occurrence; wraps around. |
| `findPrevious(text:)` | Find the previous case-insensitive occurrence; wraps around. |
| `replace(search:with:)` | Replace the current selection if it matches `search` (case-insensitive). |
| `replaceAll(search:with:)` | Replace every occurrence (case-insensitive). |

### Miscellaneous

| Method | Purpose |
| --- | --- |
| `print()` | Trigger the platform print panel. |
| `setTheme(_ theme: EditorTheme)` | Swap the editor theme at runtime. |

## EditorConfiguration Highlights

`EditorConfiguration` controls visual layout and host-supplied hooks. Two callbacks are most relevant to integrations:

| Field | Signature | Purpose |
| --- | --- | --- |
| `imageProvider` | `(@Sendable (String) -> NSImage?)?` | Resolve a Markdown image reference (filename) back into an in-line `NSImage` for preview. |
| `imageSaver` | `(@Sendable (NSImage) -> String?)?` | Persist an `NSImage` (from paste, drag, or `proxy.insertImage`) and return the URL or relative path used inside the Markdown reference. Return `nil` to opt out — the editor inserts nothing in that case. |

## License

This project is licensed under the [Mozilla Public License 2.0 (MPL-2.0)](LICENSE).
