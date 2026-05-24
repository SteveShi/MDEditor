//
//  MDEditorProxy.swift
//  MDEditor
//
//  用于外部与 MDEditorView 进行交互的代理对象
//

import Combine
import Foundation

/// MDEditor 的交互代理
/// 通过此对象可以向编辑器发送指令，如插入文本、查找替换等
public class MDEditorProxy: ObservableObject {

    // MARK: - Actions (Internal use)

    internal var insertTextAction: ((String) -> Void)?
    internal var wrapSelectionAction: ((String, String) -> Void)?
    internal var getSelectedTextAction: (() -> String?)?
    internal var getSelectedRangeAction: (() -> NSRange)?
    internal var getFullTextAction: (() -> String)?
    internal var replaceRangeAction: ((NSRange, String) -> Void)?
    internal var setSelectedRangeAction: ((NSRange) -> Void)?
    internal var findNextAction: ((String) -> Void)?
    internal var findPreviousAction: ((String) -> Void)?
    internal var replaceAction: ((String, String) -> Void)?
    internal var replaceAllAction: ((String, String) -> Void)?
    internal var printAction: (() -> Void)?
    internal var setEditorThemeAction: ((EditorTheme) -> Void)?

    // MARK: - Selection Observation

    /// 编辑器选区或光标位置发生变化时回调。
    /// 调用线程：主线程。每次 `NSTextView` 的 `textViewDidChangeSelection` 都会触发，
    /// 包括纯光标移动（无选区）的情形——便于上层做上下文敏感的 UI 切换。
    ///
    /// - Parameter range: 当前选区；`length == 0` 表示纯光标。
    /// - Parameter text: 当前编辑器完整文本（已还原 Markdown 源）。
    public var onSelectionChange: ((NSRange, String) -> Void)?

    // MARK: - Initializer

    public init() {}

    // MARK: - Public Methods

    public func insert(_ text: String) {
        insertTextAction?(text)
    }

    public func wrapSelection(prefix: String, suffix: String) {
        wrapSelectionAction?(prefix, suffix)
    }

    public func getSelectedText() -> String? {
        getSelectedTextAction?()
    }

    /// 当前选区。视图未挂载时返回 `NSRange(location: 0, length: 0)`。
    public func getSelectedRange() -> NSRange {
        getSelectedRangeAction?() ?? NSRange(location: 0, length: 0)
    }

    /// 当前编辑器完整文本（已还原 Markdown 源）。视图未挂载时返回空串。
    public func getFullText() -> String {
        getFullTextAction?() ?? ""
    }

    /// 用 `replacement` 替换 `range` 范围内的文本。
    /// 用于行级 block 前缀切换等需要原子替换的场景。
    public func replace(range: NSRange, with replacement: String) {
        replaceRangeAction?(range, replacement)
    }

    /// 设置当前选区或光标位置。
    public func setSelectedRange(_ range: NSRange) {
        setSelectedRangeAction?(range)
    }

    public func findNext(text: String) {
        findNextAction?(text)
    }

    public func findPrevious(text: String) {
        findPreviousAction?(text)
    }

    public func replace(search: String, with replacement: String) {
        replaceAction?(search, replacement)
    }

    public func replaceAll(search: String, with replacement: String) {
        replaceAllAction?(search, replacement)
    }

    public func print() {
        printAction?()
    }

    public func setTheme(_ theme: EditorTheme) {
        setEditorThemeAction?(theme)
    }
}
