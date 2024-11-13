# Deployable Neovim Configuration

A simple, deployable configuration for Neovim, designed to be cloned directly into your Neovim configuration directory and set up for a productive coding experience with popular plugins and useful mappings.

## Installation

Clone the repository into your Neovim configuration directory:

```bash
cd ~/.config
git clone https://github.com/RyanBlaney/nvim-config.git nvim
```

## Key Mappings

### Harpoon Navigation
Harpoon helps you navigate between files quickly.

- `<leader>a`: Add the current file to Harpoon.
- `<C-e>`: Toggle the Harpoon quick menu.
- `<C-h>`, `<C-t>`, `<C-n>`, `<C-s>`: Navigate to Harpoon files 1, 2, 3, and 4, respectively.

### Undotree
Use the Undotree plugin to visualize and navigate the undo history.

- `<leader>u`: Toggle the undo tree.

### Telescope (File Finder and Search)
Telescope provides file and string search functionalities.

- `<leader>pf`: Find files in the current working directory.
- `<leader>pw`: Search for text across the project using live grep.
- `<leader>ps`: Search for a specific string with a prompt.
- `<C-p>`: Find Git-tracked files.

### LSP (Language Server Protocol)
This setup provides LSP capabilities with autocomplete, diagnostics, and various language server actions.

- `<leader>vrn>`: Rename a variable or function.
- `<leader>vws>`: Workspace symbol search.
- `<leader>vd>`: Show diagnostics in a floating window.
- `<leader>vca>`: Trigger code actions.
- `K`: Hover information.
- `gd`: Go to definition.
- `gD`: Go to declaration.
- `gi`: Go to implementation.
- `go`: Go to type definition.
- `gr`: Go to references.
- `gs`: Show signature help.
- `<leader>vrf`: Format code (for `n` and `x` modes).

### Fugitive
Git integration via Fugitive.

- `<leader>gs`: Open the Git status window.

### General Remaps
Common navigation and editing shortcuts for improved productivity.

- `<leader>pv`: Open the Neovim file explorer.
- `J`, `K`: Move selected text blocks up and down in visual mode.
- `J`: Join lines while keeping the cursor in place.
- `<C-d>`, `<C-u>`: Scroll down and up, keeping the cursor centered.
- `n`, `N`: Move to the next/previous search result, centered.
- `<leader>y`: Yank to system clipboard.
- `<leader>d`: Delete to the black hole register.
- `<C-f>`: Open a new tmux window (if using tmux).
- `<leader>f`: Format the current buffer using LSP.
- `<C-k>`, `<C-j>`: Navigate through quickfix items.
- `<leader>k`, `<leader>j`: Navigate through location list items.
- `<leader>s`: Substitute the word under the cursor in the entire file.
- `<leader>x`: Make the file executable.
