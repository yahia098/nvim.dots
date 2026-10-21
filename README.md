# Yahia's Neovim Configuration

<img width="1920" height="1080" alt="Neovim configuration screenshot" src="https://github.com/user-attachments/assets/9fcddf1c-db99-43ae-a3db-837602d8bbc0" />

My personal Neovim configuration for development, written in Lua and managed with Neovim's native `vim.pack`. It is modular and tailored to the tools and workflows I actually use: LSP, completion, formatting, linting, C/C++ and CMake, Python with UV, Rust, Java, and embedded development.

<img width="1920" height="1080" alt="Neovim configuration screenshot" src="https://github.com/user-attachments/assets/969b9df7-7424-47b1-ae51-912f31f43371" />
<img width="1920" height="1080" alt="Neovim configuration screenshot" src="https://github.com/user-attachments/assets/ff3feaf3-8233-4a07-95ca-dd41d2ae8d6b" />
<img width="1920" height="1080" alt="Neovim configuration screenshot" src="https://github.com/user-attachments/assets/dcecf56c-147d-4121-a472-98b49079d332" />

## Features

- **Plugin management:** Neovim's built-in `vim.pack`, with `nvim-pack-lock.json` tracking plugin versions.
- **Completion:** `blink.cmp`, with LSP, path, snippet, and buffer sources; documentation and signature help.
- **Language servers:** `clangd`, BasedPyright, LuaLS, GLSL Analyzer, Lemminx, JSON-LSP, CSS-LS, and JDTLS.
- **Formatting:** `conform.nvim`, with format-on-save for configured filetypes.
- **Linting:** `nvim-lint`, configured to run Cppcheck, ShellCheck, Ruff, Selene, and Clippy after saving.
- **C/C++ development:** CMake Tools, standalone C/C++ execution, and dynamic Makefile target selection.
- **Project execution:** Code Runner for files and supported project markers; CMake Tools handles CMake launch targets.
- **Python:** UV-aware execution for Python files and projects.
- **Rust:** standalone `rustc` execution and Cargo project execution.
- **Navigation:** Oil file explorer and Telescope with `fzf-native`.
- **Git:** Gitsigns for hunk navigation, preview, stage, reset, and blame.
- **Interface:** Matugen colorscheme, Lualine, Which-Key, Barbar buffer tabs, Snacks dashboard/terminal/notifier, and color highlighting.
- **Embedded development:** conditional ESP-IDF integration when `IDF_PATH` is set, plus Arduino-related tooling.
- **Editing:** persistent undo, automatic pairs, snippets, and system-clipboard keymaps.

Feature availability depends on the tools installed on the system, the plugins finishing installation, and the build configuration of each project.

## Requirements

- A recent Neovim build with native `vim.pack` support.
- Git.
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

CMake Tools needs a working CMake project and a suitable generator/build tool. `telescope-fzf-native.nvim` is a native extension; `automatic.lua` attempts to build it when its `PackChanged` event fires, so CMake and a C/C++ toolchain are needed for that build.

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
├── nvim-pack-lock.json
└── lua/
    ├── automatic.lua
    ├── cmake.lua
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
    └── ui.lua
```

- `init.lua` sets the leader and loads the configuration modules in order.
- `options.lua` defines editor behavior, indentation, search, windows, and persistent undo.
- `automatic.lua` builds `telescope-fzf-native.nvim` after the relevant package change event.
- `plugins.lua` declares plugins through `vim.pack`.
- `cmake.lua` configures CMake Tools and `compile_commands.json` handling.
- `completion.lua` configures Blink completion/signature help and automatic pairs.
- `languages.lua` configures language servers, diagnostics, Java, and Arduino integration; it conditionally loads `esp.lua` when `IDF_PATH` is set.
- `formatting.lua` configures Conform and format-on-save.
- `linting.lua` configures `nvim-lint` to lint after saving.
- `runner.lua` configures Code Runner for file/project execution and configures CMake Tools.
- `keymaps.lua` contains general, navigation, Git, CMake, runner, Make, buffer, and terminal mappings.
- `explorer.lua` configures Oil.
- `ui.lua` configures the theme, statusline, Which-Key, Snacks, Telescope, Gitsigns, Barbar, and colorizer.
- `dashboard.lua` defines the Snacks dashboard sections and the `:SessionSave` command.

## Running Code and Building Projects

### Runner shortcuts

| Key | Action |
| --- | --- |
| `<leader>rr` | Run the project; routes CMake projects through CMake Tools |
| `<leader>rf` | Run the current file using its filetype command |
| `<leader>mt` | Find a Makefile above the current file and select one of its targets |

`<leader>rr` checks for a `CMakeLists.txt` above the current buffer. If found, it runs the selected CMake launch target; otherwise it calls Code Runner's project command. `<leader>rf` intentionally uses the filetype command and does not perform project-level detection.

### Supported Code Runner commands

The current `runner.lua` configuration includes:

- **C:** compile the current file with GCC using warnings and debug information, then run the executable.
- **C++:** compile the current file with G++ and C++17, then run the executable.
- **Python:** use `uv run -- python -u` for file execution.
- **Java:** compile and run the current Java file.
- **Rust:** compile standalone Rust files with `rustc`; a project with `Cargo.toml` uses `cargo run` instead.
- **Shell:** run through Bash.
- **Project markers:** Maven, Gradle, Cargo, Go, npm, UV (`uv.lock` / `pyproject.toml`), and Makefiles.

Standalone C/C++ commands compile only the current source file. For multi-file programs or projects requiring library linking, use the project's build system instead.

### CMake shortcuts

| Key | Action |
| --- | --- |
| `<leader>cg` | Generate/configure the CMake build system |
| `<leader>cb` | Build the CMake project |
| `<leader>cc` | Clean the CMake build |
| `<leader>cr` | Run the selected CMake launch target |
| `<leader>cd` | Select the CMake build type |
| `<leader>ct` | Select the CMake build target |
| `<leader>cl` | Select the CMake launch target |

CMake Tools uses a `build/` directory and enables `CMAKE_EXPORT_COMPILE_COMMANDS` for clangd and other tooling. A project must provide a valid `CMakeLists.txt`; select an executable launch target before trying to run it.

### Make target picker

`<leader>mt` searches upward from the current file for `GNUmakefile`, `Makefile`, or `makefile`. It invokes GNU Make in query/database mode (`make -qp`) and presents discovered targets using Neovim's `vim.ui.select()`. The selected target is then executed with `make -C` from the directory containing the Makefile. This means a source file in `project/src/` can use a Makefile in `project/` without hardcoding `..`.

Make target discovery is best-effort: Makefiles can use advanced syntax or generated targets that are difficult to parse completely. `make -qp` parses the Makefile and can evaluate `$(shell ...)` expressions, so only use it with Makefiles you trust.

## Keymaps

The leader key is a space (` `).

### General and clipboard

| Key | Action |
| --- | --- |
| `<leader>w` | Save the current file |
| `<leader>q` | Quit |
| `<Esc>` | Clear search highlighting |
| `y` | Yank to the system clipboard |
| `Y` | Yank lines to the system clipboard |
| `<A-y>` | Cut to the system clipboard |

### File navigation and search

| Key | Action |
| --- | --- |
| `<leader>fe` | Open Oil |
| `<leader>.` | Toggle hidden files in Oil |
| `<leader>ff` | Find files with Telescope, including hidden files |
| `<leader>fg` | Search file contents with Telescope, including hidden files |
| `<leader>fb` | Find open buffers |
| `<leader>fh` | Search Neovim help tags |

### Git

| Key | Action |
| --- | --- |
| `]c` | Next Git hunk, unless in diff mode |
| `[c` | Previous Git hunk, unless in diff mode |
| `<leader>hp` | Preview a hunk |
| `<leader>hs` | Stage a hunk |
| `<leader>hr` | Reset a hunk |
| `<leader>hb` | Blame the current line |

### Buffers

| Key | Action |
| --- | --- |
| `<leader>bn` | Next buffer |
| `<leader>bp` | Previous buffer |
| `<leader>bc` | Close the current buffer |
| `<leader>bo` | Close all buffers except the current one |
| `<leader>br` | Restore a closed buffer |
| `<leader>bt` | Pick a buffer |

### Terminal and sessions

| Key / command | Action |
| --- | --- |
| `<leader>t` | Toggle the Snacks terminal |
| `:SessionSave` | Save a Neovim session |
| Dashboard `s` | Restore the saved session when one exists |

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

Mason is configured with servers including BasedPyright, LuaLS, Lemminx, GLSL Analyzer, JDTLS, JSON-LSP, and CSS-LS. `clangd` is enabled separately. Actual server startup still depends on successful installation and each language's project setup.

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

For C/C++ projects, `compile_commands.json` helps clangd understand include paths and compiler flags. CMake Tools is configured to generate it. A project can also generate it from its root with:

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
