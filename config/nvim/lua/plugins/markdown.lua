return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      opts.linters["markdownlint-cli2"] = {
        stdin = false,
        args = {
          "--config",
          vim.fn.expand("~/.markdownlint-cli2.yaml"),
          function()
            return vim.api.nvim_buf_get_name(0)
          end,
        },
        parser = require("lint.parser").from_errorformat("%f:%l:%c %m,%f:%l %m", {
          source = "markdownlint",
          severity = vim.diagnostic.severity.WARN,
        }),
      }
      return opts
    end,
  },
}
