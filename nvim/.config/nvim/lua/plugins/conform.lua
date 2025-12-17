return {
  'stevearc/conform.nvim',
  config = function()
    require('conform').setup {
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform will run multiple formatters sequentially
        python = { 'isort', 'black', 'ruff' },
        -- You can customize some of the format options for the filetype (:help conform.format)
        rust = { 'rustfmt', lsp_format = 'fallback' },
        -- Conform will run the first available formatter
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
        sh = { 'shfmt' },
        go = { 'gofumpt', 'goimports' },
      },
      format_on_save = {
        timeout_ms = 500,
        -- lsp_fallback = true, -- Uses LSP if no formatter is found
        lsp_format = 'fallback',
      },
    }
  end,
}
