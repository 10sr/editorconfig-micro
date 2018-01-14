# editorconfig-micro

[EditorConfig][] Plugin for the [`micro`][] editor


### Prerequisites

* [Micro][micro] editor >= 1.3.2
* An `editorconfig` core executable (e.g. [EditorConfig C Core][])


### Installation

While in micro's command mode (default keybinding: <kbd>CtrlE</kbd>):

`plugin install editorconfig`

That's all! This plugin will be automatically enabled after you restart `micro`.


### Supported Properties

* `root` (only used by EditorConfig Core)
* `indent_style`
* `indent_size`
* `tab_width`
* `charset`
  * Currently, `micro` only supports the UTF-8 charset.
* `end_of_line`
  * Currently, `micro` supports only LF and CRLF.
* `insert_final_newline`
* `trim_trailing_whitespace`


### Unsupported Properties

* `max_line_length`


### License

This software is licensed under MIT License.
See [LICENSE](LICENSE) for details.

[micro]: https://micro-editor.github.io
[EditorConfig]: http://editorconfig.org
[EditorConfig C Core]: https://github.com/editorconfig/editorconfig-core-c
