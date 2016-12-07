editorconfig-micro
==================

[EditorConfig][] Plugin for [micro][] editor


Install
-------

This plugin requires an editorconfig executable be installed.
For example, download the [EditorConfig C Core][] and follow the instructions in
the README and INSTALL files to install it.

Once you installed a core program, this plugin can be (will be able to)
installed via micro plugin system (CtrlE plugin):

    > plugin install editorconfig


This plugin will be automatically enabled after you restart micro editor.


Supported Properties
--------------------

* `indent_style`
* `indent_size`
* `tab_width`
* `insert_final_newline`
* `root` (Only used by EditorConfig Core)

### On the Backlog

* `end_of_line`
  * Currently micro supports LF only
* `charset`
  * Currently micro supports UTF-8 only
* `trim_trailing_whitespace`
* `max_line_length`



License
-------

This software is licensed under MIT License.
See [LISENCE](LISENCE) for details.



[micro]: https://micro-editor.github.io
[EditorConfig]: http://editorconfig.org
[EditorConfig C Core]: https://github.com/editorconfig/editorconfig-core-c
