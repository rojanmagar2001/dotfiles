-- Standalone plugins with less than 10 lines of config go here
return {
  {
    -- autoclose tags
    'windwp/nvim-ts-autotag',
    opts = {},
  },
  {
    -- detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',
  },
  {
    -- Powerful Git integration for Vim
    'tpope/vim-fugitive',
  },
  {
    -- GitHub integration for vim-fugitive
    'tpope/vim-rhubarb',
  },
  {
    -- Hints keybinds
    'folke/which-key.nvim',
    opts = {
      delay = 3000,
      -- win = {
      --   border = {
      --     { '┌', 'FloatBorder' },
      --     { '─', 'FloatBorder' },
      --     { '┐', 'FloatBorder' },
      --     { '│', 'FloatBorder' },
      --     { '┘', 'FloatBorder' },
      --     { '─', 'FloatBorder' },
      --     { '└', 'FloatBorder' },
      --     { '│', 'FloatBorder' },
      --   },
      -- },
    },
  },
  {
    -- Autoclose parentheses, brackets, quotes, etc.
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
    opts = {},
  },
  {
    -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  {
    -- high-performance color highlighter
    'catgoose/nvim-colorizer.lua',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('colorizer').setup()
    end,
  },
  {
    -- Render markdown (headings, tables, code blocks) inside the buffer
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = { 'markdown' },
    opts = {},
    keys = {
      { '<leader>cp', '<cmd>RenderMarkdown toggle<CR>', ft = 'markdown', desc = 'Markdown [C]ode [P]review' },
    },
  },
  {
    -- Render images and mermaid diagrams inline in the buffer (needs mmdc + ImageMagick)
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = { image = { enabled = true } },
  },
  {
    -- Live markdown preview in your actual browser (needs Node.js for the build step)
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function()
      vim.fn['mkdp#util#install']()
    end,
    keys = {
      { '<leader>cP', '<cmd>MarkdownPreviewToggle<CR>', ft = 'markdown', desc = 'Markdown Browser [P]review' },
    },
  },
  {
    -- Live HTML preview in your browser with auto-reload on save
    'brianhuster/live-preview.nvim',
    cmd = { 'LivePreview' },
    ft = { 'html' },
    keys = {
      { '<leader>ch', '<cmd>LivePreview start<CR>', ft = 'html', desc = 'HTML Live Preview [S]tart' },
      { '<leader>cH', '<cmd>LivePreview close<CR>', ft = 'html', desc = 'HTML Live Preview [S]top' },
    },
  },
}
