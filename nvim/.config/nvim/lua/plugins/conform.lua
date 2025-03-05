return {
  'stevearc/conform.nvim',
  config = function()
    require('conform').setup {
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        json = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
        sh = { 'shfmt' },
        python = { 'ruff_format' },
        go = { 'gofumpt', 'goimports' },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true, -- Uses LSP if no formatter is found
      },
    }
  end,
}
