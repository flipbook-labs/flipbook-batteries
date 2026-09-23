---
bump: minor
category: Changes
---

`createLogger` is now a thin compatibility shim over [Archivist](https://github.com/flipbook-labs/archivist), flipbook-labs' logging library. The API is unchanged (`info`/`debug`/`warn`/`err`, `getLogLevel`, `LOG_LEVEL` resolution), with two behavior changes: output lines now carry a timestamp, and levels follow standard severity ordering (`debug < info < warn < err`) — previously `LOG_LEVEL=warn` also showed `info`, now it shows only `warn` and `err`.
