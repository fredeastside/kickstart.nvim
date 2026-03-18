return {
  {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false, -- This plugin is already lazy
    ft = 'rust',
    config = function()
      require('mason').setup()

      local ok, codelldb = pcall(function()
        local mason_registry = require 'mason-registry'
        local pkg = mason_registry.get_package 'codelldb'
        return pkg:get_install_path()
      end)

      if ok and codelldb then
        local extension_path = codelldb .. '/extension/'
        local codelldb_path = extension_path .. 'adapter/codelldb'
        local liblldb_path = extension_path .. 'lldb/lib/liblldb.dylib'
        local cfg = require 'rustaceanvim.config'
        vim.g.rustaceanvim = {
          dap = {
            adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
          },
        }
      end

      -- Auto-import on save: request all quickfixes and apply import suggestions
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.rs',
        callback = function(args)
          local clients = vim.lsp.get_clients { bufnr = args.buf, name = 'rust_analyzer' }
          if #clients == 0 then
            return
          end
          local client = clients[1]
          local lsp_diags = {}
          for _, d in ipairs(vim.diagnostic.get(args.buf)) do
            if d.user_data and d.user_data.lsp then
              table.insert(lsp_diags, d.user_data.lsp)
            end
          end
          if #lsp_diags == 0 then
            return
          end
          local params = {
            textDocument = vim.lsp.util.make_text_document_params(args.buf),
            context = {
              only = { 'quickfix' },
              diagnostics = lsp_diags,
            },
            range = {
              start = { line = 0, character = 0 },
              ['end'] = { line = vim.api.nvim_buf_line_count(args.buf), character = 0 },
            },
          }
          local result = client.request_sync('textDocument/codeAction', params, 3000, args.buf)
          if result and result.result then
            for _, action in ipairs(result.result) do
              if action.title and action.title:match 'importing' then
                if action.edit then
                  vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                end
              end
            end
          end
        end,
      })
    end,
  },
  {
    'rust-lang/rust.vim',
    ft = 'rust',
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
  },
  {
    'saecki/crates.nvim',
    ft = { 'toml' },
    config = function()
      require('crates').setup {
        completion = {
          cmp = {
            enabled = true,
          },
        },
      }
      require('cmp').setup.buffer {
        sources = { { name = 'crates' } },
      }
    end,
  },
}
