# Neovim Configuration

My personal Neovim configuration for development, written in Lua and organized into modules. It uses Neovim's built-in package manager, `vim.pack`, and aims to stay modular, maintainable, and practical.

## Features

- **Plugin management:** Native `vim.pack`
- **Completion:** `blink.cmp` with LSP, snippets, paths, and buffer sources
- **Language servers:** clangd, BasedPyright, LuaLS, GLSL Analyzer, Lemminx, JSON-LSP, and JDTLS
- **Build systems:** CMake Tools integration for configuring, building, cleaning, and running CMake targets
- **Terminal:** Snacks terminal for running shell commands, compilers, and executables manually
- **File navigation:** Oil
- **Fuzzy finding:** Telescope with `fzf-native`
- **Git integration:** Gitsigns for hunk navigation, previewing, staging, resetting, and blame
- **Formatting:** Conform with tools such as clang-format, Black, and Stylua; Prettierd is optional if configured for relevant filetypes
- **Linting:** `nvim-lint` with Cppcheck, ShellCheck, Ruff, Selene, and Clippy
- **Interface:** Lualine, nvim-web-devicons, which-key, TokyoNight, and Barbar for buffer tabs
- **Embedded development:** ESP-IDF integration for ESP32 projects, with ESP32 and Arduino-related plugins
- **Java support:** JDTLS through `nvim-jdtls`

The exact functionality available depends on the installed plugins, language servers, external tools, and project configuration. This setup does not use `code_runner` or the `nvim-dap` / `nvim-dap-ui` debugging plugins. Code is run manually from the terminal, while CMake Tools handles CMake projects.

## Requirements

- A Neovim version that supports the `vim.pack` workflow used by this configuration
- Git
- A C/C++ compiler for native development
- CMake and a build tool such as Ninja for CMake projects
- Python for Python development
- Node.js and npm for language tooling that requires them
- A Nerd Font is recommended if you use icon-based UI components

### Arch Linux dependencies

Install the common packages used by this configuration with:

```bash
sudo pacman -S --needed git gcc clang cmake ninja make gdb cppcheck shellcheck ruff selene nodejs npm python python-black rustup stylua fzf lazygit
```

This is a starting point, not a requirement to install every package. Remove packages for features you do not use. `gdb` is optional if you only need to compile and run programs and do not debug them manually. `lazygit` is an optional standalone Git terminal UI; it is not a Neovim plugin in the current plugin list.

For Rust linting, make sure the stable toolchain and Clippy component are installed when using `rustup`:

```bash
rustup toolchain install stable
rustup default stable
rustup component add clippy
```

Some language servers and tools can also be installed through Mason. Avoid maintaining duplicate installations unless you intentionally want to manage them separately.

### Optional dependencies

Install these only when you use the corresponding features:

- **Web formatting:** Prettierd, if it is configured in `formatting.lua` for the filetypes you use.
- **Additional language servers:** BasedPyright, GLSL Analyzer, Lemminx, JSON-LSP, and other servers configured in `languages.lua`.
- **Java:** A compatible JDK and JDTLS.
- **ESP32 development:** ESP-IDF, its toolchain, and the appropriate environment variables. The ESP-IDF installation method and package availability depend on your system.
- **Manual debugging:** GDB or the relevant language debugger, if you want to debug outside of a Neovim DAP integration.
- **Image features:** ImageMagick, only if you enable features that need it.

## Installation

**Warning:** Back up your existing Neovim configuration before replacing it.

```bash
mv ~/.config/nvim ~/.config/nvim.backup
```

Clone this repository into the Neovim configuration directory:

```bash
git clone https://github.com/yahia098/nvim.dots.git ~/.config/nvim
```

Start Neovim:

```bash
nvim
```

The configuration uses `vim.pack` to manage plugins. Allow the configured plugin-installation workflow to finish, then inspect the setup with:

```vim
:checkhealth
```

For language-server diagnostics:

```vim
:checkhealth vim.lsp
```

If you use Mason, open its interface with:

```vim
:Mason
```

## Configuration Structure

```text
.
├── init.lua
├── README.md
├── nvim-pack-lock.json
└── lua/
    ├── options.lua
    ├── plugins.lua
    ├── keymaps.lua
    ├── ui.lua
    ├── explorer.lua
    ├── completion.lua
    ├── languages.lua
    ├── formatting.lua
    ├── linting.lua
    ├── miscellaneous.lua
    └── esp.lua
```

Each Lua module is responsible for a specific part of the configuration. `init.lua` loads the modules, while `plugins.lua` declares plugins through `vim.pack`.

The `esp.lua` module is intended for ESP-IDF development and can be loaded conditionally when `IDF_PATH` is set. Keep this tree synchronized with the files that actually exist in the repository.

## Keymaps

The following mappings are defined in `keymaps.lua`. The leader key depends on your Neovim options.

### General

| Key | Action |
| --- | --- |
| `<leader>w` | Save the current file |
| `<leader>q` | Quit |
| `<Esc>` | Clear search highlighting |

### Clipboard

| Key | Action |
| --- | --- |
| `y` | Yank to the system clipboard |
| `Y` | Yank lines to the system clipboard |
| `<A-y>` | Cut to the system clipboard |

### File Navigation and Search

| Key | Action |
| --- | --- |
| `<leader>fe` | Open Oil |
| `<leader>ff` | Find files with Telescope, including hidden files |
| `<leader>fg` | Search file contents with Telescope, including hidden files |
| `<leader>fb` | Find open buffers |
| `<leader>fh` | Search Neovim help tags |

### Terminal and Build

| Key | Action |
| --- | --- |
| `<leader>tt` | Toggle the Snacks terminal |
| `<leader>cg` | Generate the CMake build system |
| `<leader>cb` | Build the CMake project |
| `<leader>cc` | Clean the CMake build |
| `<leader>cr` | Run the selected CMake launch target |
| `<leader>cd` | Select the CMake build type |
| `<leader>ct` | Select the CMake build target |
| `<leader>cl` | Select the CMake launch target |

The Snacks terminal is a terminal manager, not an automatic code runner. Use it to run commands yourself. For example, run a Python project with `uv run -- python -u main.py`; compile standalone C/C++ programs with the compiler; and use CMake Tools for projects with a `CMakeLists.txt` file.

### Git

| Key | Action |
| --- | --- |
| `]c` | Navigate to the next Git hunk, unless in diff mode |
| `[c` | Navigate to the previous Git hunk, unless in diff mode |
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

## Language Support

Language support is configured in `languages.lua`. Servers and tools must be installed separately unless the configuration installs them automatically.

- **C/C++:** clangd, GCC or Clang, CMake Tools, and Cppcheck.
- **Python:** BasedPyright, Python, and Ruff; use `uv` for projects managed with it.
- **Lua:** LuaLS, Stylua, and Selene.
- **Shell:** ShellCheck for supported shell filetypes.
- **GLSL:** GLSL Analyzer.
- **XML:** Lemminx.
- **JSON:** JSON-LSP.
- **Java:** JDTLS and a compatible Java Development Kit.
- **Rust:** A stable Rust toolchain and Clippy for Cargo projects.
- **ESP32:** ESP-IDF and its toolchain, with `IDF_PATH` set for the conditional integration.

For C/C++ projects, `compile_commands.json` is recommended because it lets clangd read the project's include paths, compiler flags, and build configuration. CMake projects can usually generate it with:

```bash
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

CMake Tools provides keymaps for generation, building, cleaning, and running targets. A valid `CMakeLists.txt` must exist in the project source directory.

## Formatting and Linting

Formatting is handled by `conform.nvim`; linting is handled by `nvim-lint`. They serve different purposes: formatters rewrite code into a consistent style, while linters report potential problems.

The current `nvim-lint` configuration runs the selected linter on `BufWritePost` (after saving):

- C/C++: `cppcheck`
- Shell: `shellcheck`
- Python: `ruff`
- Lua: `selene`
- Rust: `clippy` (requires a Cargo project)

These executable tools must be installed and visible in Neovim's `PATH`. LSP diagnostics can run alongside these linters; they are complementary, not replacements for Blink completion.

## Troubleshooting

Run the built-in health checks:

```vim
:checkhealth
```

Inspect active language servers with the command supported by your installed LSP setup, or open the LSP health report:

```vim
:checkhealth vim.lsp
```

Inspect the LSP log if a server fails to start:

```vim
:lua vim.cmd.edit(vim.lsp.log.get_filename())
```

If a plugin fails to load, verify that it is declared in `plugins.lua`, installed, and that its setup runs before any modules or keymaps that depend on it. For external tools, check them from a shell with `command -v <tool>` and verify that Neovim can see them through its `PATH`.

## Note

This configuration is a work in progress.

## License

This repository contains my personal Neovim configuration. Unless a license is explicitly added to the repository, all rights remain with the author.
