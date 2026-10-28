# Yahia's Neovim Configuration

<img width="1920" height="1080" alt="Neovim configuration screenshot" src="https://github.com/user-attachments/assets/9fcddf1c-db99-43ae-a3db-837602d8bbc0" />

My personal Neovim configuration for development, written in Lua and managed with Neovim's native `vim.pack`. It is modular and tailored to the tools and workflows I actually use: LSP, completion, formatting, linting, C/C++ and CMake, Python with UV, Rust, Java, and embedded development.

<img width="1920" height="1080" alt="Neovim configuration screenshot" src="https://github.com/user-attachments/assets/969b9df7-7424-47b1-ae51-912f31f43371" />
<img width="1920" height="1080" alt="Neovim configuration screenshot" src="https://github.com/user-attachments/assets/ff3feaf3-8233-4a07-95ca-dd41d2ae8d6b" />
<img width="1920" height="1080" alt="Neovim configuration screenshot" src="https://github.com/user-attachments/assets/dcecf56c-147d-4121-a472-98b49079d332" />

## Features

- **Plugin management:** Neovim's built-in `vim.pack`. Every download happens first at startup (`plugins.lua`, no confirmation prompt), and each remaining module loads in protected mode so one failure cannot stop the rest.
- **Completion:** `blink.cmp` with LSP, path, snippet, and buffer sources. `Tab` / `Shift-Tab` walk the menu, `Enter` accepts, and arrow keys are left alone.
- **Language servers:** `clangd`, BasedPyright, LuaLS, GLSL Analyzer, Lemminx, JSON-LSP, CSS-LS, and JDTLS.
- **Formatting and linting:** `conform.nvim` (format on save) and `nvim-lint` (after saving; linters that are not installed are skipped).
- **Building and running:** Code Runner for files and projects, plus CMake, Make, Cargo, Maven, Gradle, and UV project actions under `<leader>r`.
- **Navigating large codebases:** project-root-aware Telescope pickers, Git pickers, jump/mark/quickfix pickers, LSP folding, call hierarchy, numbered buffer jumps, and automatic handling of very large files.
- **Search and refactor:** grug-far for project-wide search and replace, Trouble for diagnostics, references, and symbols lists.
- **Git:** Gitsigns for hunks, plus Telescope Git pickers.
- **Interface:** Matugen colorscheme (falls back to tokyonight), Lualine, Which-Key, Barbar buffer tabs, Snacks dashboard/terminal/notifier, and color highlighting.
- **Neovide:** font, animations, zoom, fullscreen, and paste, all enabled only inside Neovide.
- **Embedded development:** conditional ESP-IDF integration when `IDF_PATH` is set, plus Arduino tooling.
- **Editing:** persistent undo, automatic pairs, snippets, 2-space indentation (real tabs in Makefiles), and clipboard-safe deleting and pasting.

Feature availability depends on the tools installed on the system, the plugins finishing installation, and the build configuration of each project.

## Requirements

- Neovim 0.12 or newer (native `vim.pack`).
- Git.
- ripgrep (`rg`) for grug-far and faster `:grep`.
- A C/C++ compiler (GCC or Clang).
- CMake and GNU Make; Ninja is useful for projects configured to use it.
- UV and Python for UV-managed Python projects.
- Rust and Cargo for Rust projects.
- A compatible JDK for Java development.
- Node.js and npm for tools that require them.
- A Nerd Font is recommended for icon-bearing UI components.

The configured language servers, formatters, and linters must also be installed. Mason is configured for several language servers; external commands such as `cppcheck`, `shellcheck`, `ruff`, `selene`, `clippy`, `black`, `clang-format`, and `prettierd` still need to be available where their filetypes use them.

### Arch Linux packages

This is a starting point, not a mandatory all-in-one install. Install only the tools needed for the languages and features you use:

```bash
sudo pacman -S --needed git gcc clang cmake ninja make nodejs npm python python-black rustup stylua fzf cppcheck shellcheck selene
```

Install UV and any tools not available through your selected package source separately. For Rust linting, install a stable toolchain and Clippy:

```bash
rustup toolchain install stable
rustup default stable
rustup component add clippy
```

`telescope-fzf-native.nvim` is a native extension; `automatic.lua` attempts to build it when its `PackChanged` event fires, so CMake and a C/C++ toolchain are needed for that build.

### Local Matugen theme

The UI loads the Matugen colorscheme using this path:

```text
~/.config/matugen/templates/colors-nvim.json
```

Make sure your Matugen setup generates that file, or adjust the path in `lua/ui.lua` for your system.

## Installation

Back up any existing configuration before replacing it:

```bash
mv ~/.config/nvim ~/.config/nvim.backup
```

Clone this repository as your Neovim configuration:

```bash
git clone https://github.com/yahia098/nvim.dots.git ~/.config/nvim
```

Launch Neovim and let the `vim.pack` setup install declared plugins:

```bash
nvim
```

Then inspect the environment:

```vim
:checkhealth
:checkhealth vim.lsp
:Mason
```

The `Mason` command opens Mason's package UI. It does not guarantee that every non-LSP external tool used by formatting or linting is installed.

## Configuration Layout

```text
.
├── init.lua
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

- `init.lua` sets the leader, enables the Lua module cache, loads `options`, `automatic` and `plugins` first, then loads the other modules in protected mode.
- `options.lua` defines editor behavior, indentation, search, folds, persistent undo, and the Neovide settings.
- `automatic.lua` builds `telescope-fzf-native.nvim` after install, sets Makefile and C/C++ indentation, and holds the general autocommands (yank flash, restore cursor, auto-reload, create missing folders on save, close helper windows with `q`).
- `plugins.lua` declares plugins through `vim.pack`.
- `completion.lua` configures Blink completion/signature help and automatic pairs.
- `languages.lua` configures language servers, LSP keymaps, diagnostics, Java, and Arduino integration; it conditionally loads `esp.lua` when `IDF_PATH` is set.
- `formatting.lua` configures Conform and format-on-save.
- `linting.lua` configures `nvim-lint`.
- `runner.lua` configures Code Runner for file/project execution.
- `tools.lua` configures Trouble and grug-far.
- `keymaps.lua` contains the general, navigation, Git, runner, buffer, terminal, and Neovide mappings.
- `explorer.lua` configures Oil.
- `ui.lua` configures the theme, statusline, Which-Key, Snacks, Telescope, Gitsigns, Barbar, and colorizer.
- `dashboard.lua` defines the Snacks dashboard sections and the `:SessionSave` command.
- `scripts/cmake_targets.sh` lists CMake executable targets through CMake's File API.

## Running Code and Building Projects

### Runner shortcuts

| Key | Action |
| --- | --- |
| `<leader>rr` | Run the project |
| `<leader>rf` | Run the current file using its filetype command |
| `<leader>rt` | Select a target: CMake executable targets, otherwise Make targets |
| `<leader>rb` | Build the nearest project with its native build tool |
| `<leader>rc` | Clean the nearest project |

CMake projects use a `build/` directory and `scripts/cmake_targets.sh`, which discovers executable targets through CMake's File API. Other projects (Maven, Gradle, Cargo, Go, npm, UV, Makefiles) are detected from their marker files.

### Supported Code Runner commands

- **C:** compile the current file with GCC using warnings and debug information, then run the executable.
- **C++:** compile the current file with G++ and C++17, then run the executable.
- **Python:** use `uv run -- python -u` for file execution.
- **Java:** compile and run the current Java file.
- **Rust:** compile standalone Rust files with `rustc`; a project with `Cargo.toml` uses `cargo run` instead.
- **Shell:** run through Bash.

Standalone C/C++ commands compile only the current source file. For multi-file programs, use the project's build system.

### Make target picker

`<leader>rt` searches upward from the current file for `GNUmakefile`, `Makefile`, or `makefile` when no CMake project is found. It uses GNU Make's query/database mode (`make -qp`) and shows the discovered targets with `vim.ui.select()`; the chosen target runs with `make -C` from the Makefile's directory. Target discovery is best-effort, and `make -qp` can evaluate `$(shell ...)`, so only use it with Makefiles you trust.

## Keymaps

The leader key is a space. Press `<leader>` and wait for Which-Key to show the available groups.

### General, clipboard and editing

| Key | Action |
| --- | --- |
| `<leader>w` | Save |
| `<leader>W` | Save all |
| `<C-s>` | Save (any mode) |
| `<leader>q` | Quit |
| `<Esc>` | Clear search highlighting |
| `y / Y` | Yank (lines) to the system clipboard |
| `<A-y>` | Cut to the system clipboard |
| `d, D, c, C, x, X` | Delete or change without touching any register |
| `p / P` | Paste the system clipboard |
| `<A-j> / <A-k>` | Move the line or selection down / up |
| `< / > (visual)` | Indent and keep the selection |
| `j / k` | Move by screen line on wrapped lines (counts still work) |
| `<C-d> / <C-u>, n / N` | Scroll and search with the cursor centered |
| `J` | Join lines without moving the cursor |
| `<leader>a` | Select the whole file |
| `* (visual)` | Search for the selected text |
| `<leader>sr` | Replace the word under the cursor in the file |
| `<leader>cx` | Make the current file executable |

### Windows and buffers

| Key | Action |
| --- | --- |
| `<C-h/j/k/l>` | Move between windows (also from a terminal) |
| `<C-arrows>` | Resize the window |
| `<leader>sv / sh` | Split vertically / horizontally |
| `<leader>se / sx` | Equalize / close splits |
| `<leader>z` | Maximize the window |
| `<leader><Tab>` | Next window |
| `<leader><leader>` | Alternate file |
| `<A-,> / <A-.>` | Previous / next buffer |
| `<A-<> / <A->>` | Move the buffer left / right |
| `<A-1> ... <A-9>, <A-0>` | Go to buffer 1-9 / the last buffer |
| `<A-c> / <A-p>` | Close / pin the buffer |
| `<leader>bn bp bc bo br bt` | Next, previous, close, close others, restore, pick |
| `Mouse back / forward` | Jump back / forward in the jumplist |

### Files, search and projects

| Key | Action |
| --- | --- |
| `<leader>fe` | Open Oil |
| `<leader>.` | Toggle hidden files in Oil |
| `<leader>ff / fg` | Find files / grep (cwd) |
| `<leader>fp / fP` | Find files / grep from the project root |
| `<leader>f. / f,` | Find files / grep in the current file folder |
| `<leader>fO` | Grep in open buffers |
| `<leader>fb / fh` | Buffers / help tags |
| `<leader>fr` | Recent files |
| `<leader>fw` | Search the word under the cursor |
| `<leader>fz or <leader>/` | Search in the current buffer |
| `<leader>fd` | Diagnostics |
| `<leader>fs / fS` | Symbols in the file / project |
| `<leader>fk` | Keymaps |
| `<leader>fj / fm / fq` | Jumplist / marks / quickfix |
| `<leader>fR` | Resume the last picker |
| `<leader>cr or :Root` | cd to the project root |
| `<leader>cd` | cd to the current file folder |
| `<leader>sg` | Search and replace in the project (selection in visual mode) |
| `<leader>sw` | Search and replace the word under the cursor |
| `<leader>sf` | Search and replace in this file |

### Git

| Key | Action |
| --- | --- |
| `]c / [c` | Next / previous hunk |
| `<leader>hp hs hr hb` | Preview, stage, reset a hunk; blame the line |
| `<leader>gf` | Git files |
| `<leader>gs` | Git status |
| `<leader>gc / gC` | Commits / commits for this file |
| `<leader>gb` | Branches |

### LSP, diagnostics and lists

| Key | Action |
| --- | --- |
| `gd / gD / gy` | Go to definition / declaration / type |
| `Ctrl+click` | Go to definition |
| `<leader>lr` | Rename |
| `<leader>la` | Code action |
| `<leader>lf` | Format |
| `<leader>ls` | Signature help |
| `<leader>lR / li` | References / implementations |
| `<leader>lc / lC` | Incoming / outgoing calls |
| `<leader>lh` | Toggle inlay hints |
| `<leader>e` | Diagnostic float |
| `<leader>dl / dq` | Diagnostics in the buffer / project (list) |
| `<leader>dt` | Toggle diagnostics |
| `<leader>co / cc` | Open / close the quickfix window |
| `<leader>xx / xX` | Trouble: project / buffer diagnostics |
| `<leader>xs` | Trouble: symbols |
| `<leader>xr` | Trouble: LSP references |
| `<leader>xl / xq` | Trouble: location / quickfix list |

### Terminal, sessions and Neovide

| Key | Action |
| --- | --- |
| `<leader>t` | Toggle the Snacks terminal |
| `<Esc><Esc>` | Leave terminal mode |
| `:SessionSave` | Save a session (dashboard s restores it) |
| `<C-=> / <C--> / <C-0>` | Neovide: zoom in / out / reset |
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

When started from Neovide, the config sets a Nerd Font (`JetBrainsMono Nerd Font Mono`, size 14), short scroll and cursor animations, window padding, a remembered window size, zoom (`<C-=>`, `<C-->`, `<C-0>`), fullscreen (`<F11>`), and `<C-S-v>` paste. These settings live in `options.lua` and `keymaps.lua` behind `vim.g.neovide`, so a terminal Neovim is unaffected.

## Language Servers, Formatting, and Linting

Language servers are configured in `languages.lua`. The setup includes:

- **C/C++:** clangd.
- **Python:** BasedPyright.
- **Lua:** LuaLS.
- **GLSL:** GLSL Analyzer.
- **XML:** Lemminx.
- **JSON:** JSON-LSP.
- **CSS:** CSS-LS.
- **Java:** JDTLS through `nvim-jdtls`.
- **Arduino:** Arduino-Nvim setup on the `arduino` filetype.
- **ESP32:** the ESP-IDF integration loads when `IDF_PATH` is set.

Mason (on desktop) is configured with servers including BasedPyright, LuaLS, Lemminx, GLSL Analyzer, JDTLS, JSON-LSP, and CSS-LS. `clangd` is enabled separately. Actual server startup still depends on successful installation and each language's project setup.

### Formatting

Conform is configured to format on save, with LSP fallback enabled, for these filetypes:

| Filetype | Formatter |
| --- | --- |
| C / C++ | `clang_format` |
| Lua | `stylua` |
| Python | `black` |
| JSON / JSONC, YAML, Markdown, HTML, CSS | `prettierd` |

The executable for the selected formatter must be available. For example, Prettierd is needed only when formatting one of the filetypes assigned to it.

### Linting

`nvim-lint` is configured to run on `BufWritePost` (after saving):

| Filetype | Linter |
| --- | --- |
| C / C++ | `cppcheck` |
| Shell / Bash | `shellcheck` |
| Python | `ruff` |
| Lua | `selene` |
| Rust | `clippy` |

Install these tools and ensure Neovim can find them in `PATH`. Clippy is a Rust component and works in the context of Cargo projects; it is not a general standalone `.rs` linter. LSP diagnostics and external linters can be active at the same time and provide different kinds of feedback.

For C/C++ projects, `compile_commands.json` helps clangd understand include paths and compiler flags. A project can generate it from its root with:

```bash
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

## Troubleshooting

1. Run `:checkhealth` and `:checkhealth vim.lsp`.
2. Open `:Mason` to inspect configured language-server packages.
3. Check external executables from a shell, for example `command -v clangd`, `command -v cppcheck`, or `command -v uv`.
4. If a plugin fails to load, confirm it appears in `plugins.lua`, has installed successfully, and its setup runs before code that calls it.
5. If a language server fails, inspect the LSP log with:

   ```vim
   :lua vim.cmd.edit(vim.lsp.log.get_filename())
   ```

## AI Assistance and Authorship

This is my personal configuration, shaped around my workflow through experimentation, customization, and ongoing maintenance. Most of the setup reflects my own configuration work.

**`lua/runner.lua` is the clearest exception: it was developed with intensive, iterative AI assistance.** AI contributed substantially to its design, implementation, debugging, and documentation. The related project-routing and Make-target-picker portions of `lua/keymaps.lua` were also refined with AI during that work. I supplied the goals and requirements, made the integration choices, and am continuing to review and learn the implementation, but I do not present this runner work as code written entirely by me without AI assistance.

The rest of the configuration is primarily my own setup and customization. I am documenting this distinction intentionally: I want to understand the code I use, maintain it, and be able to explain the choices behind it rather than treating it as a black box.

## License

This repository contains my personal Neovim configuration. Unless a license is explicitly added to the repository, all rights remain with the author.
