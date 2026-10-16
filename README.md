# Neovim Configuration

My personal Neovim configuration for development, written in Lua and organized into modules. It uses Neovim's built-in package manager, `vim.pack`, and focuses on keeping the setup modular, maintainable, and practical.

## Features

- **Plugin management:** Native `vim.pack`
- **Completion:** `blink.cmp` with LSP, snippets, paths, and buffer sources
- **Language servers:** clangd, BasedPyright, LuaLS, GLSL Analyzer, Lemminx, JSON-LSP, and JDTLS
- **Debugging:** `nvim-dap` and `nvim-dap-ui`
- **Code execution:** `code_runner`
- **File navigation:** Oil
- **Fuzzy finding:** Telescope with `fzf-native`
- **Git integration:** Gitsigns and Lazygit
- **Formatting:** Stylua, Black, and Prettierd
- **Linting:** Cppcheck, ShellCheck, Ruff, and Selene
- **Interface:** Lualine, nvim-web-devicons, and which-key
- **Embedded development:** ESP-IDF integration for ESP32 projects

The exact functionality available depends on the installed plugins, language servers, and external tools.

## Requirements

- Neovim with `vim.pack` support
- Git
- A C/C++ compiler and debugger for native development
- Node.js and npm for relevant language tooling
- Python for Python development
- A Nerd Font is recommended if you use icon-based UI components

### Arch Linux dependencies

Install the common system packages with:

```bash
sudo pacman -Syu --needed git gcc clang gdb cmake ninja cppcheck shellcheck ruff selene nodejs npm python python-black python-debugpy rustup stylua lazygit fzf imagemagick
```

Some tools may be installed through Mason or another package manager instead. Package availability can vary by repository and architecture.

### Optional dependencies

Install these only if you use the corresponding features:

- **Java:** A JDK and JDTLS, plus `java-debug-adapter` for Java debugging.
- **Rust-based plugin builds:** Rust and Cargo i put rustup on my pc and use stable , if required by your installed plugin versions.
- **Web formatting:** Prettierd (forgot why i added it).
- **Additional language servers:** BasedPyright, GLSL Analyzer, Lemminx, JSON-LSP, and other servers configured in `languages`.lua file.
- **ESP32 development:** ESP-IDF from the aur, its toolchain, and the appropriate environment variables.

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

Install or synchronize plugins using the package-management workflow supported by your configuration and Neovim version. Then check the installation:

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
    ├── debugger.lua
    ├── miscellaneous.lua
    └── esp.lua
```

Each Lua module is responsible for a specific part of the configuration. `init.lua` loads the modules, while `plugins.lua` manages plugin installation.

The `esp.lua` module is intended for ESP-IDF development and can be loaded conditionally when `IDF_PATH` is set.

## Keymaps

The following mappings are defined in `keymaps.lua`. The leader key depends on your Neovim options.

### General

| Key         | Action                    |
| ----------- | ------------------------- |
| `<leader>w` | Save the current file     |
| `<leader>q` | Quit                      |
| `<Esc>`     | Clear search highlighting |

### Clipboard

| Key     | Action                             |
| ------- | ---------------------------------- |
| `y`     | Yank to the system clipboard       |
| `Y`     | Yank lines to the system clipboard |
| `<A-y>` | Cut to the system clipboard        |

### File Navigation

| Key          | Action                    |
| ------------ | ------------------------- |
| `<leader>fe` | Open Oil                  |
| `<leader>ff` | Find files with Telescope |
| `<leader>fg` | Search file contents      |
| `<leader>fb` | Find open buffers         |
| `<leader>fh` | Search Neovim help        |

### Debugging

| Key          | Action                           |
| ------------ | -------------------------------- |
| `<F5>`       | Start or continue debugging      |
| `<S-F5>`     | Terminate debugging              |
| `<F10>`      | Step over                        |
| `<F11>`      | Step into                        |
| `<F12>`      | Step out                         |
| `<leader>dp` | Pause execution                  |
| `<leader>dl` | Run the last debug configuration |
| `<leader>b`  | Toggle breakpoint                |
| `<leader>B`  | Set a conditional breakpoint     |
| `<leader>dc` | Clear all breakpoints            |
| `<leader>du` | Toggle the DAP UI                |
| `<leader>dr` | Open the DAP REPL                |
| `<leader>de` | Evaluate an expression           |

Debugging requires a compatible adapter and debugger for the language being used.

### Code Runner

| Key         | Action                  |
| ----------- | ----------------------- |
| `<leader>r` | Execute code            |
| `<leader>R` | Run the current file    |
| `<leader>P` | Run the current project |
| `<leader>X` | Close the runner        |

### Git

| Key          | Action                            |
| ------------ | --------------------------------- |
| `]c`         | Navigate to the next Git hunk     |
| `[c`         | Navigate to the previous Git hunk |
| `<leader>hp` | Preview a hunk                    |
| `<leader>hs` | Stage a hunk                      |
| `<leader>hr` | Reset a hunk                      |
| `<leader>hb` | Blame the current line            |

## Language Support

Language support is configured in `languages.lua`. Servers and tools must be installed separately unless the configuration installs them automatically.

- **C/C++:** clangd, GCC or Clang, and GDB or another configured debug adapter.
- **Python:** BasedPyright, Python, and debugpy if Python debugging is enabled.
- **Lua:** LuaLS and Stylua.
- **GLSL:** GLSL Analyzer.
- **XML:** Lemminx.
- **JSON:** JSON-LSP.
- **Java:** JDTLS and a compatible Java Development Kit.

For C/C++ projects, a `compile_commands.json` compilation database is recommended. It allows clangd to understand the project's include paths, compiler flags, and build configuration. CMake projects can usually generate one with `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`.

## Debugging Notes

- **C/C++:** Build the program with debug symbols and configure the DAP adapter to use the resulting executable.
- **Python:** Install debugpy and ensure the configured adapter can locate it.
- **Java:** Configure JDTLS and the Java debug adapter. Java debugging is separate from language-server functionality.

DAP keymaps alone do not configure a working debugger. Each language needs a valid adapter and launch configuration.

## Troubleshooting

Run the built-in health checks:

```vim
:checkhealth
```

Inspect active language servers:

```vim
:LspInfo
```

Inspect the LSP log if a server fails to start:

```vim
:lua vim.cmd.edit(vim.lsp.log.get_filename())
```

If a plugin fails to load, verify that it is installed, its dependencies are available, and its setup function runs before any keymaps or modules that depend on it.

## &#x20;Note

this is a WIP

## License

This repository contains my personal Neovim configuration. Unless a license is explicitly added to the repository, all rights remain with the author.
