# herdr adapter

`config.toml` is the only hand-authored file in `~/.config/herdr`. Everything
else there is generated: `plugins.json` records absolute plugin paths and
resolved commits, `session.json` is live session state, and the sockets, logs,
and plugin clones are runtime artifacts.

Plugins are not restorable from `plugins.json`, so reinstall them by source:

```bash
herdr plugin install smarzban/herdr-file-viewer
herdr plugin install persiyanov/herdr-reviewr
herdr plugin install devashish2203/herdr-worktrunk
```

The `keys.command` bindings in `config.toml` reference `herdr-file-viewer`
actions, so install that one before expecting those keys to work.
