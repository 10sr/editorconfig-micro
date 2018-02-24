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

Once installed, this plugin will automatically execute `editorconfig.getApplyProperties`
on files when they are opened or saved.

You can also explicitly use the `editorconfig` command in command mode, or bind it to
a keystroke. For example:

```json
{
    "Alt-e": "editorconfig.getApplyProperties"
}
```

If any editorconfig properties have been changed, they will be logged, which can be viewed
with `log` in command mode. If you want to see verbose logs, you must manually add `"editorconfigverbose": true,` to your user settings in `~/.config/micro/settings.json`.


[EditorConfig]: http://editorconfig.org
[EditorConfig C Core]: https://github.com/editorconfig/editorconfig-core-c
