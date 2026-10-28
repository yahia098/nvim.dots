# Yahia's Neovim Configuration

<img width="1920" height="1080" alt="Neovim configuration screenshot" src="https://github.com/user-attachments/assets/9fcddf1c-db99-43ae-a3db-837602d8bbc0" />

My personal Neovim configuration, written in Lua and managed with [lazy.nvim](https://github.com/folke/lazy.nvim). It is modular, tuned for the tools I actually use, and built around three things: LSP-based development, fast navigation in large codebases, and running or building projects without leaving the editor. It covers C/C++ and CMake, Python with UV, Rust, Java, Lua, and embedded work (ESP-IDF and Arduino).

<img width="1920" height="1080" alt="Neovim configuration screenshot" src="https://github.com/user-attachments/assets/969b9df7-7424-47b1-ae51-912f31f43371" />
<img width="1920" height="1080" alt="Neovim configuration screenshot" src="https://github.com/user-attachments/assets/ff3feaf3-8233-4a07-95ca-dd41d2ae8d6b" />
<img width="1920" height="1080" alt="Neovim configuration screenshot" src="https://github.com/user-attachments/assets/dcecf56c-147d-4121-a472-98b49079d332" />

## Features

- **Plugins:** lazy.nvim installs missing plugins in parallel on first start. Every plugin loads at startup so the other modules can `require()` it directly. `init.lua` loads each module in protected mode, so one broken plugin is reported instead of aborting the rest.
- **Completion:** `blink.cmp` with LSP, path, snippet and buffer sources. `Tab` / `Shift-Tab` walk the menu, `Enter` accepts, arrow keys are left alone.
- **Language servers:** clangd, BasedPyright, LuaLS, GLSL Analyzer, Lemminx, JSON-LSP, CSS-LS and JDTLS.
- **Formatting and linting:** `conform.nvim` (format on save) and `nvim-lint` (after saving; linters that are not installed are skipped).
- **Building and running:** Code Runner for files and projects, plus CMake, Make, Cargo, Maven, Gradle and UV project actions under `<leader>r`.
- **Large codebases:** project-root-aware Telescope pickers, Git pickers, jump/mark/quickfix pickers, LSP folding, call hierarchy, numbered buffer jumps, and automatic handling of very large files.
- **Search and refactor:** grug-far for project-wide search and replace, Trouble for diagnostics, references and symbol lists.
- **Git:** Gitsigns for hunks, plus Telescope Git pickers.
- **Interface:** Matugen colorscheme (falls back to tokyonight), Lualine, Which-Key, Barbar buffer tabs, Snacks dashboard, terminal and notifier, and color highlighting.
- **Neovide:** font, animations, zoom, fullscreen and paste, enabled only inside Neovide.
- **Embedded:** ESP-IDF integration when `IDF_PATH` is set, plus Arduino tooling.
- **Editing:** persistent undo, automatic pairs, snippets, 2-space indentation (real tabs in Makefiles), and clipboard-safe deleting and pasting.

Which features work depends on the tools installed on your system and on each project's build setup.

## Requirements

- Neovim 0.12 or newer.
- Git.
- ripgrep (`rg`) and `fd` for the pickers and grug-far.
- A C/C++ compiler (GCC or Clang), plus CMake and GNU Make. `cmake` is also needed to build `telescope-fzf-native.nvim`.
- Rust and Cargo, for Rust projects and for building blink.cmp's native fuzzy-matching library.
- UV and Python for UV-managed Python projects.
- A JDK **17 or newer** for Java. JDTLS will not start on Java 8.
- Node.js and npm for tools that need them.
- A Nerd Font (JetBrainsMono Nerd Font recommended) for icons.

Language servers, formatters and linters beyond what Mason installs must be available in `PATH` (`cppcheck`, `shellcheck`, `ruff`, `selene`, `clippy`, `black`, `clang-format`, `prettierd`).

### Arch Linux packages

A starting point, not a mandatory install:

```bash
sudo pacman -S --needed git gcc clang cmake ninja make ripgrep fd nodejs npm python python-black rustup stylua fzf cppcheck shellcheck selene jdk21-openjdk
```

Install UV separately, then set up Rust:

```bash
rustup toolchain install stable
rustup default stable
rustup component add clippy
```

### Matugen theme

The UI loads the Matugen colorscheme from:

```text
~/.config/matugen/templates/colors-nvim.json
```

Make sure your Matugen setup generates that file, or change the path in `lua/ui.lua`. If the file is missing, the config falls back to tokyonight.

## Installation

Back up any existing configuration first:

```bash
mv ~/.config/nvim ~/.config/nvim.backup
```

Clone this repository and start Neovim:

```bash
git clone https://github.com/yahia098/nvim.dots.git ~/.config/nvim
nvim
```

On first start lazy.nvim clones itself and every plugin. **Let it finish before quitting**, then restart Neovim once. Quitting mid-install can leave half-cloned plugin folders that cause "module not found" errors later (see Troubleshooting).

Then check the environment:

```vim
:checkhealth
:checkhealth vim.lsp
:Lazy
:Mason
```

## Plugin management

| Command | Action |
| --- | --- |
| `:Lazy` | Open the plugin manager |
| `:Lazy sync` | Install, update and clean (fetches every plugin, so it is slower than a normal start) |
| `:Lazy install` | Install only what is missing |
| `:Lazy restore` | Restore plugins to the revisions in `lazy-lock.json` |
| `:Lazy build <plugin>` | Re-run a plugin's build step |

`lazy-lock.json` pins plugin revisions; commit it so another machine gets the same versions. `telescope-fzf-native.nvim` is built by lazy through its `build` field, which needs CMake.

## Configuration layout

```text
.
├── init.lua
├── lazy-lock.json
├── README.md
├── scripts/
│   └── cmake_targets.sh
└── lua/
    ├── automatic.lua
    ├── completion.lua
    ├── dashboard.lua
    ├── esp.lua
    ├── explorer.lua
    ├── formatting.lua
    ├── keymaps.lua
    ├── languages.lua
    ├── linting.lua
    ├── options.lua
    ├── plugins.lua
    ├── runner.lua
    ├── tools.lua
    └── ui.lua
```

- `init.lua` sets the leader, enables the Lua module cache, disables unused providers and built-in plugins, loads `options`, `automatic` and `plugins`, then loads the remaining modules in protected mode.
- `options.lua` holds editor behavior, indentation, search, folds, persistent undo and the Neovide settings.
- `automatic.lua` holds general autocommands: Makefile and C/C++ indentation, yank flash, restoring the cursor position, auto-reload, creating missing folders on save, and closing helper windows with `q`.
- `plugins.lua` bootstraps lazy.nvim and declares every plugin.
- `completion.lua` configures Blink completion and signature help, plus automatic pairs.
- `languages.lua` configures Mason, language servers, LSP keymaps, diagnostics, Java and Arduino. It conditionally loads `esp.lua` when `IDF_PATH` is set.
- `formatting.lua` configures Conform and format on save.
- `linting.lua` configures `nvim-lint`.
- `runner.lua` configures Code Runner for file and project execution.
- `tools.lua` configures Trouble and grug-far.
- `keymaps.lua` holds the general, navigation, Git, runner, buffer, terminal and Neovide mappings.
- `explorer.lua` configures Oil.
- `ui.lua` configures the theme, statusline, Which-Key, Snacks, Telescope, Gitsigns, Barbar and the colorizer.
- `dashboard.lua` defines the Snacks dashboard and the `:SessionSave` command.
- `scripts/cmake_targets.sh` lists and runs CMake executable targets through CMake's File API.

## Running code and building projects

| Key | Action |
| --- | --- |
| `<leader>rr` | Run the project |
| `<leader>rf` | Run the current file using its filetype command |
| `<leader>rt` | Pick a target: CMake executables, otherwise Make targets |
| `<leader>rb` | Build the nearest project with its native build tool |
| `<leader>rc` | Clean the nearest project |

CMake projects use a `build/` directory and `scripts/cmake_targets.sh`. Other projects (Maven, Gradle, Cargo, Go, npm, UV, Makefiles) are detected from their marker files.

Code Runner commands for single files:

- **C:** compile with GCC (warnings and debug info), then run.
- **C++:** compile with G++ and C++17, then run.
- **Python:** `uv run -- python -u`.
- **Java:** compile and run the current file.
- **Rust:** `rustc` for standalone files; a project with `Cargo.toml` uses `cargo run`.
- **Shell:** run through Bash.

Standalone C/C++ commands compile only the current file. For multi-file programs use the project's build system.

`<leader>rt` falls back to Make when there is no CMake project. It searches upward for `GNUmakefile`, `Makefile` or `makefile`, reads targets with `make -qp`, and runs the chosen one with `make -C`. Target discovery is best-effort, and `make -qp` can evaluate `$(shell ...)`, so only use it on Makefiles you trust.

## Keymaps

The leader key is Space. Press `<leader>` and wait for Which-Key to list the groups.

### General, clipboard and editing

| Key | Action |
| --- | --- |
| `<leader>w` / `<leader>W` | Save / save all |
| `<C-s>` | Save (any mode) |
| `<leader>q` | Quit |
| `<Esc>` | Clear search highlighting |
| `y` / `Y` | Yank (lines) to the system clipboard |
| `<A-y>` | Cut to the system clipboard |
| `d D c C x X` | Delete or change without touching any register |
| `p` / `P` | Paste the system clipboard |
| `<A-j>` / `<A-k>` | Move the line or selection down / up |
| `<` / `>` (visual) | Indent and keep the selection |
| `j` / `k` | Move by screen line on wrapped lines (counts still work) |
| `<C-d>` `<C-u>` `n` `N` | Scroll and search with the cursor centered |
| `J` | Join lines without moving the cursor |
| `<leader>a` | Select the whole file |
| `*` (visual) | Search for the selected text |
| `<leader>sr` | Replace the word under the cursor in the file |
| `<leader>cx` | Make the current file executable |

### Windows and buffers

| Key | Action |
| --- | --- |
| `<C-h/j/k/l>` | Move between windows (also from a terminal) |
| `<C-arrows>` | Resize the window |
| `<leader>sv` / `<leader>sh` | Split vertically / horizontally |
| `<leader>se` / `<leader>sx` | Equalize / close splits |
| `<leader>z` | Maximize the window |
| `<leader><Tab>` | Next window |
| `<leader><leader>` | Alternate file |
| `<A-,>` / `<A-.>` | Previous / next buffer |
| `<A-<>` / `<A->>` | Move the buffer left / right |
| `<A-1>` ... `<A-9>`, `<A-0>` | Go to buffer 1-9 / the last buffer |
| `<A-c>` / `<A-p>` | Close / pin the buffer |
| `<leader>bn bp bc bo br bt` | Next, previous, close, close others, restore, pick |
| Mouse back / forward | Jump back / forward in the jumplist |

### Files, search and projects

| Key | Action |
| --- | --- |
| `<leader>fe` | Open Oil |
| `<leader>.` | Toggle hidden files in Oil |
| `<leader>ff` / `<leader>fg` | Find files / grep (cwd) |
| `<leader>fp` / `<leader>fP` | Find files / grep from the project root |
| `<leader>f.` / `<leader>f,` | Find files / grep in the current file's folder |
| `<leader>fO` | Grep in open buffers |
| `<leader>fb` / `<leader>fh` | Buffers / help tags |
| `<leader>fr` | Recent files |
| `<leader>fw` | Search the word under the cursor |
| `<leader>fz` or `<leader>/` | Search in the current buffer |
| `<leader>fd` | Diagnostics |
| `<leader>fs` / `<leader>fS` | Symbols in the file / project |
| `<leader>fk` | Keymaps |
| `<leader>fj` / `<leader>fm` / `<leader>fq` | Jumplist / marks / quickfix |
| `<leader>fR` | Resume the last picker |
| `<leader>cr` or `:Root` | `cd` to the project root |
| `<leader>cd` | `cd` to the current file's folder |
| `<leader>sg` | Search and replace in the project (selection in visual mode) |
| `<leader>sw` | Search and replace the word under the cursor |
| `<leader>sf` | Search and replace in this file |

### Git

| Key | Action |
| --- | --- |
| `]c` / `[c` | Next / previous hunk |
| `<leader>hp hs hr hb` | Preview, stage, reset a hunk; blame the line |
| `<leader>gf` | Git files |
| `<leader>gs` | Git status |
| `<leader>gc` / `<leader>gC` | Commits / commits for this file |
| `<leader>gb` | Branches |

### LSP, diagnostics and lists

| Key | Action |
| --- | --- |
| `gd` / `gD` / `gy` | Go to definition / declaration / type |
| `Ctrl+click` | Go to definition |
| `<leader>lr` | Rename |
| `<leader>la` | Code action |
| `<leader>lf` | Format |
| `<leader>ls` | Signature help |
| `<leader>lR` / `<leader>li` | References / implementations |
| `<leader>lc` / `<leader>lC` | Incoming / outgoing calls |
| `<leader>lh` | Toggle inlay hints |
| `<leader>e` | Diagnostic float |
| `<leader>dl` / `<leader>dq` | Diagnostics in the buffer / project (list) |
| `<leader>dt` | Toggle diagnostics |
| `<leader>co` / `<leader>cc` | Open / close the quickfix window |
| `<leader>xx` / `<leader>xX` | Trouble: project / buffer diagnostics |
| `<leader>xs` | Trouble: symbols |
| `<leader>xr` | Trouble: LSP references |
| `<leader>xl` / `<leader>xq` | Trouble: location / quickfix list |

### Terminal, sessions and Neovide

| Key | Action |
| --- | --- |
| `<leader>t` | Toggle the Snacks terminal (floating) |
| `<Esc><Esc>` | Leave terminal mode |
| `:SessionSave` | Save a session (`s` on the dashboard restores it) |
| `<C-=>` / `<C-->` / `<C-0>` | Neovide: zoom in / out / reset |
| `<F11>` | Neovide: fullscreen |
| `<C-S-v>` | Neovide: paste the system clipboard (insert, command line, terminal) |

### Completion

| Key | Action |
| --- | --- |
| `<Tab>` / `<S-Tab>` | Next / previous item, or jump through snippet fields |
| `<CR>` | Accept the selected item |
| `<C-n>` / `<C-p>` | Next / previous item |
| `<C-Space>` | Open the menu or documentation |
| `<C-e>` | Close the menu |
| `<C-b>` / `<C-f>` | Scroll the documentation |
| `<C-k>` | Toggle signature help |

## Neovide

When started from Neovide the config sets `JetBrainsMono Nerd Font Mono` at size 14, short scroll and cursor animations, window padding, a remembered window size, zoom, fullscreen and `<C-S-v>` paste. These settings live in `options.lua` and `keymaps.lua` behind `vim.g.neovide`, so a terminal Neovim is unaffected.

## Language servers, formatting and linting

Servers are configured in `languages.lua`:

- **C/C++:** clangd
- **Python:** BasedPyright
- **Lua:** LuaLS
- **GLSL:** GLSL Analyzer
- **XML:** Lemminx
- **JSON:** JSON-LSP
- **CSS:** CSS-LS
- **Java:** JDTLS through `nvim-jdtls` (needs JDK 17+)
- **Arduino:** Arduino-Nvim, on the `arduino` filetype
- **ESP32:** ESP-IDF integration, loaded when `IDF_PATH` is set

Mason installs the servers above plus the formatters and linters it can provide (`clangd`, `clang-format`, `stylua`, `black`, `prettierd`, `shellcheck`, `ruff`, `selene`).

### Formatting

Conform formats on save with LSP fallback:

| Filetype | Formatter |
| --- | --- |
| C / C++ | `clang_format` |
| Lua | `stylua` |
| Python | `black` |
| JSON / JSONC, YAML, Markdown, HTML, CSS | `prettierd` |

### Linting

`nvim-lint` runs after saving:

| Filetype | Linter |
| --- | --- |
| C / C++ | `cppcheck` |
| Shell / Bash | `shellcheck` |
| Python | `ruff` |
| Lua | `selene` |
| Rust | `clippy` |

Clippy is a Cargo component, so it only works inside Cargo projects. LSP diagnostics and external linters can be active at the same time.

For C/C++ projects, `compile_commands.json` helps clangd find include paths and compiler flags:

```bash
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

## blink.cmp native library

`blink.cmp` uses a native fuzzy-matching library (`implementation = "rust"` in `completion.lua`). On the main branch it is compiled from source with Cargo, which can take several minutes on first install and after blink.cmp updates. If you want to avoid compiling, set `implementation = "lua"` (slower on very large completion lists) or pin blink.cmp to a release tag so it can download a prebuilt binary. `:checkhealth blink.cmp` shows which one is in use.

## Troubleshooting

1. Run `:checkhealth` and `:checkhealth vim.lsp`.
2. Run `:Lazy` and look for plugins marked as failed. `:Lazy log` shows details.
3. **"module '...' not found":** a plugin folder is probably incomplete, usually from an interrupted install. Delete its folder in `~/.local/share/nvim/lazy/` and run `:Lazy install`.
4. **A fetch fails with "Connection reset by peer":** retry with `:Lazy sync <plugin>`. If it keeps happening, add `concurrency = 4` to the options table at the bottom of `plugins.lua`.
5. **Java files get no language server:** check `java -version`; JDTLS needs JDK 17 or newer.
6. **Check external tools** from a shell, for example `command -v clangd`, `command -v cppcheck` or `command -v uv`.
7. **Inspect the LSP log:**

   ```vim
   :lua vim.cmd.edit(vim.lsp.log.get_filename())
   ```

## AI assistance and authorship

This is my personal configuration, shaped around my workflow through experimentation, customization and ongoing maintenance. Most of the setup reflects my own configuration work.

**`lua/runner.lua` is the clearest exception: it was developed with intensive, iterative AI assistance.** AI contributed substantially to its design, implementation, debugging and documentation. The related project-routing and Make-target-picker parts of `lua/keymaps.lua` were also refined with AI during that work. I supplied the goals and requirements, made the integration choices, and am continuing to review and learn the implementation, but I do not present this runner work as code written entirely by me without AI assistance.

The rest of the configuration is primarily my own setup and customization. I am documenting this distinction on purpose: I want to understand the code I use, maintain it, and be able to explain the choices behind it rather than treat it as a black box.

## License

This repository contains my personal Neovim configuration. Unless a license is explicitly added, all rights remain with the author.
