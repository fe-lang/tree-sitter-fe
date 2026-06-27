# tree-sitter-fe

[tree-sitter](https://tree-sitter.github.io/) grammar for the
[Fe language](https://fe-lang.org/).

> **This repository is a generated mirror.** The grammar source of truth lives
> in [argotorg/fe](https://github.com/argotorg/fe) at `crates/tree-sitter-fe`.
> There, the generated parser (`parser.c`, `grammar.json`, `node-types.json`,
> wasm) is **not** tracked — it bloats diffs. This repo regenerates and commits
> those artifacts so editors and other tools have a stable git tree to clone and
> build, with `src/parser.c` present.

## How it's updated

A scheduled workflow ([`.github/workflows/sync.yml`](.github/workflows/sync.yml))
regenerates the grammar from `argotorg/fe`:

- **`main`** tracks `argotorg/fe@master`; it is auto-committed whenever the
  grammar changes. Use this to test in-progress grammar work.
- **Release tags** (e.g. `v26.3.0`) mirror the corresponding `argotorg/fe`
  release and are the refs editor integrations should normally pin. Each tag
  also gets a GitHub release with the compiled `tree-sitter-fe.wasm` attached.

The `.source-commit` file records the exact `argotorg/fe` commit each revision
was generated from.

To regenerate locally or point `main` at an arbitrary fe ref, run the sync
script (or the `Sync grammar from fe` workflow's manual dispatch):

```sh
scripts/sync-from-fe.sh <branch|tag|sha>   # default: master
```

It needs `node`/`npm` (installs the pinned tree-sitter CLI). Building the wasm
additionally needs `emcc` (Emscripten).

## Consuming the grammar

Point your editor integration at this repo with the standard root layout
(`src/parser.c`, `src/scanner.c`, `queries/`), pinning a release tag:

- **Zed**: `repository = "https://github.com/fe-lang/tree-sitter-fe"`, `commit = "<sha>"`
- **Emacs (treesit)**: `("https://github.com/fe-lang/tree-sitter-fe" "v26.3.0" "src")`
- **Neovim / nvim-treesitter**: clone this repo at the tag and compile `src/parser.c`
