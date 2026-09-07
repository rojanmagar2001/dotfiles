-- Highlight, edit, and navigate code
local ensure_installed = {
  'lua',
  'python',
  'javascript',
  'typescript',
  'vimdoc',
  'vim',
  'regex',
  'terraform',
  'sql',
  'dockerfile',
  'toml',
  'json',
  'java',
  'groovy',
  'go',
  'gitignore',
  'graphql',
  'yaml',
  'make',
  'cmake',
  'markdown',
  'markdown_inline',
  'bash',
  'tsx',
  'css',
  'html',
}

-- Turn on treesitter highlighting and indenting for a buffer, installing the
-- parser first if it is missing.
local function attach(buf)
  if vim.bo[buf].filetype == '' then
    return
  end

  local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)

  local function start()
    if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then
      return false
    end
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    return true
  end

  local ts = require 'nvim-treesitter'
  if not start() and vim.tbl_contains(ts.get_available(), lang) then
    ts.install(lang):await(vim.schedule_wrap(start))
  end
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install(ensure_installed)

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-attach', { clear = true }),
        callback = function(args)
          attach(args.buf)
        end,
      })

      -- The autocommand above misses buffers already loaded at startup
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          attach(buf)
        end
      end

      -- Incremental selection. Neovim provides `an` (parent node) and `in`
      -- (child node) as visual mode text objects; these keep the old bindings.
      vim.keymap.set('n', '<c-space>', 'van', { remap = true, desc = 'Select node' })
      vim.keymap.set('x', '<c-space>', 'an', { remap = true, desc = 'Grow selection to parent node' })
      vim.keymap.set('x', '<M-space>', 'in', { remap = true, desc = 'Shrink selection to child node' })

      -- Register additional file extensions
      vim.filetype.add { extension = { tf = 'terraform' } }
      vim.filetype.add { extension = { tfvars = 'terraform' } }
      vim.filetype.add { extension = { pipeline = 'groovy' } }
      vim.filetype.add { extension = { multibranch = 'groovy' } }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    init = function()
      -- Built-in ftplugin mappings are buffer local and would shadow the
      -- global `]]`, `[[` and friends set below
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
        },
        move = {
          -- whether to set jumps in the jumplist
          set_jumps = true,
        },
      }

      local select = require 'nvim-treesitter-textobjects.select'
      local move = require 'nvim-treesitter-textobjects.move'
      local swap = require 'nvim-treesitter-textobjects.swap'

      -- You can use the capture groups defined in textobjects.scm
      for key, capture in pairs {
        aa = '@parameter.outer',
        ia = '@parameter.inner',
        af = '@function.outer',
        ['if'] = '@function.inner',
        ac = '@class.outer',
        ic = '@class.inner',
      } do
        vim.keymap.set({ 'x', 'o' }, key, function()
          select.select_textobject(capture, 'textobjects')
        end, { desc = 'Select ' .. capture })
      end

      for _, spec in ipairs {
        { ']m', move.goto_next_start, '@function.outer' },
        { ']]', move.goto_next_start, '@class.outer' },
        { ']M', move.goto_next_end, '@function.outer' },
        { '][', move.goto_next_end, '@class.outer' },
        { '[m', move.goto_previous_start, '@function.outer' },
        { '[[', move.goto_previous_start, '@class.outer' },
        { '[M', move.goto_previous_end, '@function.outer' },
        { '[]', move.goto_previous_end, '@class.outer' },
      } do
        local key, goto_node, capture = spec[1], spec[2], spec[3]
        vim.keymap.set({ 'n', 'x', 'o' }, key, function()
          goto_node(capture, 'textobjects')
        end, { desc = 'Jump to ' .. capture })
      end

      vim.keymap.set('n', '<leader>a', function()
        swap.swap_next '@parameter.inner'
      end, { desc = 'Swap parameter with next' })
      vim.keymap.set('n', '<leader>A', function()
        swap.swap_previous '@parameter.inner'
      end, { desc = 'Swap parameter with previous' })
    end,
  },
}
