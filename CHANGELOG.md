# CHANGELOG

## 1.7.0

### Changes
- Added `EditorTheme` and `EditorThemeColor` to expose full editor theming (background, foreground, headings, syntax markers, emphasis, inline code, code block background, blockquote, link, insertion point).
- `EditorConfiguration` now accepts a `theme:` parameter; `MDEditorView` and `MarkdownHighlighter` consume the theme instead of a hard-coded `isDarkTheme` flag.
- `MDEditorProxy.setTheme(_:)` replaces the previous dark-mode toggle, allowing host apps to drive a complete color scheme.

### Breaking
- Removed `MarkdownHighlighter.isDarkTheme` and `MDEditorProxy.updateTheme(isDark:)`. Host apps must migrate to `EditorTheme`.

---

### 变更
- 新增 `EditorTheme` 与 `EditorThemeColor`，完整开放编辑器配色（背景、正文、标题、语法标记、强调、行内代码、代码块底色、引用、链接、光标）。
- `EditorConfiguration` 新增 `theme:` 参数；`MDEditorView` 与 `MarkdownHighlighter` 改用主题对象，不再依赖硬编码的 `isDarkTheme` 开关。
- `MDEditorProxy.setTheme(_:)` 取代旧的深色模式切换，宿主 App 可统一驱动整套配色。

### 不兼容变更
- 移除 `MarkdownHighlighter.isDarkTheme` 与 `MDEditorProxy.updateTheme(isDark:)`，宿主需迁移到 `EditorTheme`。

## 1.6.2

### Changes
- Unified Markdown parsing stack by migrating to `MarkdownParser` from the `MarkdownView` package.
- Removed redundant `apple/swift-markdown` dependency to streamline the project architecture.
- Refactored `MarkdownConverter` for better performance and consistency between editor highlighting and HTML export.

---

### 变更
- 统一了 Markdown 解析栈，迁移至 `MarkdownView` 库中的 `MarkdownParser`。
- 移除了冗余的 `apple/swift-markdown` 依赖，简化了项目架构。
- 重构了 `MarkdownConverter`，提升了性能并确保了编辑器高亮与 HTML 导出效果的一致性。
