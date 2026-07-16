vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Plugin manager
require('lazy').setup("plugins")
--
-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
--vim.wo.number = true
vim.opt.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 10

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Fix Tabs
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 0
vim.o.softtabstop = 0
vim.o.autoindent = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

--Keymap to set and unset relative/absolute line number (stolen from nvchad)
vim.keymap.set('n', '<leader>m', '<cmd> set nu! <CR>', { desc = 'toggle line number' })
vim.keymap.set('n', '<leader>rm', '<cmd> set rnu! <CR>', { desc = 'toggle relative number' })
vim.keymap.set('n', '<leader>fm', vim.lsp.buf.format, { desc = 'Format file' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>s.', function() require('telescope.builtin').find_files({ hidden = true }) end,
  { desc = '[S]earch Hidden ([.])Files' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>st', require('telescope.builtin').git_files, { desc = '[S]earch Gi[t]' })

-- Disable italics
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local groups = vim.api.nvim_get_hl(0, {})
    for group, opts in pairs(groups) do
      if opts.italic then
        opts.italic = false
        vim.api.nvim_set_hl(0, group, opts)
      end
    end
  end,
})

-- Also run it immediately for the current colorscheme
vim.schedule(function()
  local groups = vim.api.nvim_get_hl(0, {})
  for group, opts in pairs(groups) do
    if opts.italic then
      opts.italic = false
      vim.api.nvim_set_hl(0, group, opts)
    end
  end
end)

-- Compiler
-- Open compiler
vim.api.nvim_set_keymap('n', '<F6>', "<cmd>CompilerOpen<cr>", { noremap = true, silent = true })

-- Redo last selected option
vim.api.nvim_set_keymap('n', '<S-F6>',
  "<cmd>CompilerStop<cr>"    -- (Optional, to dispose all tasks before redo)
  .. "<cmd>CompilerRedo<cr>",
  { noremap = true, silent = true })

-- Toggle compiler results
vim.api.nvim_set_keymap('n', '<S-F7>', "<cmd>CompilerToggleResults<cr>", { noremap = true, silent = true })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter` (nvim-treesitter `main` branch API)
--
-- The `main` branch dropped the old `require('nvim-treesitter.configs').setup{}`
-- module system. Parsers are installed via `require('nvim-treesitter').install()`
-- and highlighting is enabled per-buffer with `vim.treesitter.start()`.

-- Parsers to keep installed. markdown + markdown_inline are included so fenced
-- code-block injections highlight correctly.
local ts_parsers = {
  'c', 'cpp', 'go', 'hlsl', 'lua', 'python', 'rust', 'tsx', 'typescript',
  'vimdoc', 'vim', 'odin', 'markdown', 'markdown_inline',
}
require('nvim-treesitter').install(ts_parsers)

-- Enable treesitter highlighting for any buffer whose language has a parser.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Start treesitter highlighting',
  callback = function(args)
    -- Silently no-op for filetypes without an installed parser.
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- [[ Incremental selection ]]
-- Reimplemented manually since the `main` branch removed this module.
local ts_sel_history = {}

local function ts_update_selection(node)
  local sr, sc, er, ec = node:range()
  local end_row, end_col = er + 1, ec
  if ec == 0 then
    end_row = er
    end_col = vim.v.maxcol
  end
  vim.fn.setpos('.', { 0, sr + 1, sc + 1, 0 })
  vim.cmd('normal! v')
  vim.fn.setpos('.', { 0, end_row, end_col, 0 })
end

local function ts_same_range(a, b)
  local a1, a2, a3, a4 = a:range()
  local b1, b2, b3, b4 = b:range()
  return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
end

local function ts_init_selection()
  local node = vim.treesitter.get_node()
  if not node then return end
  ts_sel_history = { node }
  ts_update_selection(node)
end

local function ts_node_incremental()
  local node = ts_sel_history[#ts_sel_history]
  if not node then return ts_init_selection() end
  local parent = node:parent()
  while parent and ts_same_range(parent, node) do
    parent = parent:parent()
  end
  if parent then
    table.insert(ts_sel_history, parent)
    ts_update_selection(parent)
  end
end

local function ts_node_decremental()
  if #ts_sel_history > 1 then
    table.remove(ts_sel_history)
  end
  local node = ts_sel_history[#ts_sel_history]
  if node then ts_update_selection(node) end
end

vim.keymap.set('n', '<c-space>', ts_init_selection, { desc = 'Init treesitter selection' })
vim.keymap.set('x', '<c-space>', ts_node_incremental, { desc = 'Increment treesitter selection' })
vim.keymap.set('x', '<c-s>', ts_node_incremental, { desc = 'Increment treesitter selection (scope)' })
vim.keymap.set('x', '<M-space>', ts_node_decremental, { desc = 'Decrement treesitter selection' })

-- [[ Treesitter textobjects (main branch API) ]]
require('nvim-treesitter-textobjects').setup {
  select = {
    lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
  },
  move = {
    set_jumps = true, -- whether to set jumps in the jumplist
  },
}

local ts_select = require('nvim-treesitter-textobjects.select')
local ts_swap = require('nvim-treesitter-textobjects.swap')
local ts_move = require('nvim-treesitter-textobjects.move')

-- select
for lhs, query in pairs({
  ['aa'] = '@parameter.outer',
  ['ia'] = '@parameter.inner',
  ['af'] = '@function.outer',
  ['if'] = '@function.inner',
  ['ac'] = '@class.outer',
  ['ic'] = '@class.inner',
}) do
  vim.keymap.set({ 'x', 'o' }, lhs, function()
    ts_select.select_textobject(query, 'textobjects')
  end, { desc = 'Select ' .. query })
end

-- swap
vim.keymap.set('n', '<leader>a', function()
  ts_swap.swap_next('@parameter.inner')
end, { desc = 'Swap next parameter' })
vim.keymap.set('n', '<leader>A', function()
  ts_swap.swap_previous('@parameter.inner')
end, { desc = 'Swap previous parameter' })

-- move
for fn, maps in pairs({
  goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
  goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
  goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
  goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
}) do
  for lhs, query in pairs(maps) do
    vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
      ts_move[fn](query, 'textobjects')
    end, { desc = fn .. ' ' .. query })
  end
end

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set('n', '<leader>lf', vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set('n', '<leader>ll', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
vim.keymap.set('n', '<leader>ls', vim.lsp.buf.signature_help, { desc = "Open floating language signature" })

-- LSP settings using the new vim.lsp.config API

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Configure LSP servers using the new vim.lsp.config API
-- Configure each server with vim.lsp.config instead of lspconfig

-- C/C++
vim.lsp.config('clangd', {
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = { 'clangd', "--fallback-style=google" },
})

-- Set indentation for specific file types
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "c", "cpp", "h", "hpp" },
--   callback = function()
--     vim.opt_local.tabstop = 2
--   end,
-- })

-- Go
vim.lsp.config('gopls', {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- TypeScript/JavaScript
vim.lsp.config('eslint', {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config('tsserver', {
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
})

-- LaTeX
vim.lsp.config('texlab', {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Java
vim.lsp.config('jdtls', {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Lua
vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})


-- Odin
vim.lsp.config('ols', {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      enable_overload_resolution = true,
      enable_inlay_hints_params = true,
      enable_inlay_hints_default_params = true,
      enable_inlay_hints_implicit_return = true,
      enable_inlay_hints_optional_result = true,
      enable_semantic_tokens = true,
      enable_snippets = true,
      enable_comp_lit_signature_help = true,
      enable_comp_lit_signature_help_use_docs = true,
      enable_code_action_invert_if = true,

      enable_checker_only_saved = false,
    }
})

-- Zig
vim.lsp.config('zls', {
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "zig", "zon" },
  settings = {
    enableAutofix = true,
    enable_snippets = true,
    enable_ast_check_diagnostics = true,
    enable_autofix = true,
    enable_import_embedfile_argument_completions = true,
    warn_style = true,
    enable_semantic_tokens = true,
    enable_inlay_hints = true,
    inlay_hints_hide_redundant_param_names = true,
    inlay_hints_hide_redundant_param_names_last_token = true,
    operator_completions = true,
    include_at_in_builtins = true,
    max_detail_length = 1048576,
    zig_exe_path = 'C:/Users/halop/.zvm/bin/zig.exe',
  },
  cmd = { 'C:/Users/halop/.zvm/bin/zls.exe' }
})

-- Zig (manual setup since it may not be migrated to vim.lsp.config yet)
-- require('lspconfig')['zls'].setup {
--   capabilities = capabilities,
--   on_attach = on_attach,
--   settings = {
--     enableAutofix = true,
--     enable_snippets = true,
--     enable_ast_check_diagnostics = true,
--     enable_autofix = true,
--     enable_import_embedfile_argument_completions = true,
--     warn_style = true,
--     enable_semantic_tokens = true,
--     enable_inlay_hints = true,
--     inlay_hints_hide_redundant_param_names = true,
--     inlay_hints_hide_redundant_param_names_last_token = true,
--     operator_completions = true,
--     include_at_in_builtins = true,
--     max_detail_length = 1048576,
--     zig_exe_path='C:/Users/halop/.zvm/bin/zig.exe',
--     zls_exe_path='C:/Users/halop/.zvm/bin/zls.exe'
--   },
--   cmd = { 'C:/Users/halop/.zvm/bin/zls.exe'}
-- }

-- Setup neovim lua configuration
require('neodev').setup()

require('mason').setup()

-- Setup mason-lspconfig with the new v2 API
require("mason-lspconfig").setup {
  ensure_installed = {
    "clangd",
    "gopls",
    "eslint",
    "tsserver",
    "texlab",
    "jdtls",
    "lua_ls",
    "ols"
  },
  -- automatic_enable is enabled by default in v2
  -- This will automatically vim.lsp.enable() installed servers
  automatic_enable = true,
}

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'luasnip' },
    { name = 'omni' },
    { name = 'nvim_lua' }
  },
}
-- Windows PDF viewer options
if vim.fn.has('win32') == 1 then
  vim.g.vimtex_view_method = 'general'
  vim.g.vimtex_view_general_viewer = 'SumatraPDF'
  -- Or use: vim.g.vimtex_view_general_viewer = 'start'
else
  vim.g.vimtex_view_method = 'zathura'
end

--nvim-tree setup
--

local tree = require 'nvim-tree'

local function nvim_tree_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)
end

vim.keymap.set('n', '<C-n>', '<cmd> NvimTreeToggle <CR>', { desc = 'Toggle nvimtree' })
vim.keymap.set('n', '<leader>e', '<cmd> NvimTreeFocus <CR>', { desc = 'Focus nvimtree' })

tree.setup {
  on_attach = nvim_tree_on_attach,
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
