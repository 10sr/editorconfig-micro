editorconfig-micro
==================

[EditorConfig][] helps developers define and maintain
consistent coding styles between different editors and IDEs.
This is the EditorConfig plugin for the `micro` editor.

This plugin requires an editorconfig core executable to be installed.
For example, download the [EditorConfig C Core][] and follow the instructions in
the README and INSTALL files to install it.


Usage
-----

Once installed, this plugin will automatically execute `editorconfig` for
current files and apply properties when opening buffers for them. `editorconfig`
will also be executed upon every file save.

This plugin also provides one command: `editorconfig`.
You can use this command to explicitly apply properties after updating
`.editorconfig` files.

By default there are no keybindings for this command, but you can bind a key to
this command in your `bindings.json`. For example:

``` json
{
    "Alt-e": "editorconfig.getApplyProperties"
}
```

[EditorConfig]: http://editorconfig.org
[EditorConfig C Core]: https://github.com/editorconfig/editorconfig-core-c
