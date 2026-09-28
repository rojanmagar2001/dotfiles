-- Fuzzy Finder (files, lsp, etc)
return {
  'nvim-telescope/telescope.nvim',
  -- branch = '0.1.x',
  branch = 'master',
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    'nvim-telescope/telescope-ui-select.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { '<leader>sb', function() require('telescope.builtin').buffers() end, desc = '[S]earch existing [B]uffers' },
    { '<leader><tab>', function() require('telescope.builtin').buffers() end, desc = '[S]earch existing [B]uffers' },
    { '<leader><leader>', function() require('telescope.builtin').buffers() end, desc = '[ ] Find existing buffers' },
    { '<leader>sm', function() require('telescope.builtin').marks() end, desc = '[S]earch [M]arks' },
    { '<leader>gf', function() require('telescope.builtin').git_files() end, desc = 'Search [G]it [F]iles' },
    { '<leader>gc', function() require('telescope.builtin').git_commits() end, desc = 'Search [G]it [C]ommits' },
    { '<leader>gcf', function() require('telescope.builtin').git_bcommits() end, desc = 'Search [G]it [C]ommits for current [F]ile' },
    { '<leader>gb', function() require('telescope.builtin').git_branches() end, desc = 'Search [G]it [B]ranches' },
    { '<leader>gs', function() require('telescope.builtin').git_status() end, desc = 'Search [G]it [S]tatus (diff view)' },
    { '<leader>sf', function() require('telescope.builtin').find_files() end, desc = '[S]earch [F]iles' },
    { '<leader>sh', function() require('telescope.builtin').help_tags() end, desc = '[S]earch [H]elp' },
    { '<leader>sw', function() require('telescope.builtin').grep_string() end, desc = '[S]earch current [W]ord' },
    { '<leader>sg', function() require('telescope.builtin').live_grep() end, desc = '[S]earch by [G]rep' },
    { '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc = '[S]earch [D]iagnostics' },
    { '<leader>sr', function() require('telescope.builtin').resume() end, desc = '[S]earch [R]resume' },
    { '<leader>so', function() require('telescope.builtin').oldfiles() end, desc = '[S]earch Recent Files' },
    {
      '<leader>sds',
      function()
        require('telescope.builtin').lsp_document_symbols {
          symbols = { 'Class', 'Function', 'Method', 'Constructor', 'Interface', 'Module', 'Property' },
        }
      end,
      desc = '[S]each LSP document [S]ymbols',
    },
    {
      '<leader>s/',
      function()
        require('telescope.builtin').live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end,
      desc = '[S]earch [/] in Open Files',
    },
    {
      '<leader>/',
      function()
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          previewer = false,
        })
      end,
      desc = '[/] Fuzzily search in current buffer',
    },
  },
  config = function()
    local actions = require 'telescope.actions'

    require('telescope').setup {
      defaults = {
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            prompt_position = 'bottom',
            preview_width = 0.6,
            width = { padding = 0 },
            height = { padding = 0 },
          },
        },
        mappings = {
          i = {
            ['<C-k>'] = actions.move_selection_previous, -- move to prev result
            ['<C-j>'] = actions.move_selection_next, -- move to next result
            ['<C-l>'] = actions.select_default, -- open file
          },
          n = {
            ['q'] = actions.close,
          },
        },
      },
      pickers = {
        find_files = {
          file_ignore_patterns = { 'node_modules', '.git', '.venv' },
          hidden = true,
        },
        buffers = {
          initial_mode = 'normal',
          sort_lastused = true,
          -- sort_mru = true,
          mappings = {
            n = {
              ['d'] = actions.delete_buffer,
              ['l'] = actions.select_default,
            },
          },
        },
        marks = {
          initial_mode = 'normal',
        },
        oldfiles = {
          initial_mode = 'normal',
        },
      },
      live_grep = {
        file_ignore_patterns = { 'node_modules', '.git', '.venv' },
        additional_args = function(_)
          return { '--hidden' }
        end,
      },
      path_display = {
        filename_first = {
          reverse_directories = true,
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
      git_files = {
        previewer = false,
      },
    }

    -- Enable telescope fzf native, if installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
  end,
}
