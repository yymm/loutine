import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Quillエディタとツールバーを含むWidget
class NoteEditor extends StatelessWidget {
  const NoteEditor({
    super.key,
    required this.controller,
  });

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: _buildEditor(),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return QuillSimpleToolbar(
      controller: controller,
      config: QuillSimpleToolbarConfig(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        buttonOptions: const QuillSimpleToolbarButtonOptions(
          base: QuillToolbarBaseButtonOptions(
            iconSize: 18,
            iconButtonFactor: 1.2,
          ),
        ),
        toolbarSize: 40,
        multiRowsDisplay: false,
        // Markdown対応: 構造
        showHeaderStyle: true,
        showListNumbers: true,
        showListBullets: true,
        showListCheck: true,
        showCodeBlock: true,
        showQuote: true,
        showLink: true,
        // Markdown対応: テキスト装飾
        showBoldButton: true,
        showItalicButton: true,
        showStrikeThrough: true,
        showInlineCode: true,
        // 操作
        showUndo: false,
        showRedo: false,
        // 非表示項目
        showIndent: false,
        showUnderLineButton: false,
        showColorButton: false,
        showBackgroundColorButton: false,
        showClearFormat: false,
        showAlignmentButtons: false,
        showLeftAlignment: false,
        showCenterAlignment: false,
        showRightAlignment: false,
        showJustifyAlignment: false,
        showDirection: false,
        showSearchButton: false,
        showSubscript: false,
        showSuperscript: false,
        showFontFamily: false,
        showFontSize: false,
        showDividers: false,
      ),
    );
  }

  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: QuillEditor.basic(
        controller: controller,
        config: const QuillEditorConfig(
          padding: EdgeInsets.zero,
          placeholder: 'free write...',
          customStyles: DefaultStyles(
            placeHolder: DefaultTextBlockStyle(
              TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              HorizontalSpacing(0, 0),
              VerticalSpacing(0, 0),
              VerticalSpacing(0, 0),
              null,
            ),
          ),
        ),
      ),
    );
  }
}
