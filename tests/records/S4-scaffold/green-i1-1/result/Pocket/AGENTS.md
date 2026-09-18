# Architecture

This project follows the `app-architecture` skill: every module is a Swift package under
`Packages/`, and its directory prefix is its layer — `fm-` Feature, `bm-` Business, `lib-`
Library. Dependencies point down only, and a business module never imports UI.

`make verify` is the gate. Run it before you call a task done; it runs every package's tests,
the architecture tests, and a zero-warning lint.

The Xcode project is generated from `project.yml` by XcodeGen and is gitignored — never
hand-edit it, and never commit it.
