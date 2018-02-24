# editorconfig-micro

[EditorConfig] plugin for the [`micro`] editor.


### Prerequisites

* [`micro`] editor >= 1.3.2
* An `editorconfig` core executable (e.g. [EditorConfig C Core])


### Installation

While in micro's command mode (default keybinding: <kbd>CtrlE</kbd>):

`plugin install editorconfig`

That's all! This plugin will be automatically enabled after you restart [`micro`]. It will automatically apply the appropriate editorconfig properties on files when they are opened or saved.

For more information, use `help editorconfig` in command mode or view `help/editorconfig.md` in this repo.


### Supported Properties

* `root` (only used by EditorConfig Core)
* `indent_style`
* `indent_size`
* `tab_width`
* `charset`
  * Currently, [`micro`] only [supports][EditorConfig Options] the `utf-8` charset.
* `end_of_line`
  * Currently, [`micro`] only [supports][EditorConfig Options] `lf` and `crlf`.
* `insert_final_newline`
* `trim_trailing_whitespace`


### Unsupported Properties

* `max_line_length`


### License

This software is licensed under MIT License.
See [LICENSE](LICENSE) for details.

[`micro`]: https://micro-editor.github.io
[EditorConfig]: http://editorconfig.org
[EditorConfig Options]: https://github.com/zyedidia/micro/blob/master/runtime/help/options.md
[EditorConfig C Core]: https://github.com/editorconfig/editorconfig-core-c
