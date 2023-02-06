require("mason").setup()
require('plugins')
require('opts')
require('keys')
local rt = require("rust-tools")
local set = vim.opt

-- global config store
_G.edn = {}

local store = {}

local fmt = string.format

local function store_fn(fn)
  table.insert(store, fn)
  local index = #store
  return fmt([[lua require('event')._exec(%d)]], index)
end

local cmd = vim.api.nvim_command

local function construct_cmd(event, spec)
  local is_table = type(spec) == "table"
  local pattern = is_table and spec[1] or "*"
  local action = is_table and spec[2] or spec

  if type(action) == "function" then
    action = store_fn(action)
  end

  event = type(event) == "table" and table.concat(event, ",") or event
  cmd(fmt([[autocmd %s %s %s]], event, pattern, action))
end

local function construct_group(name, cmds)
  cmd("augroup " .. name)
  cmd("autocmd!")
  for _, au in ipairs(cmds) do
    local event = table.remove(au, 1)
    construct_cmd(event, #au == 1 and au[1] or au)
  end
  cmd("augroup END")
end

local au = setmetatable({}, {
  __newindex = function(_, event, cmds)
    construct_cmd(event, cmds)
  end,
  __call = function(_, event, pattern, action)
    construct_cmd(event, action == nil and pattern or { pattern, action })
  end,
})

local aug = setmetatable({}, {
  __newindex = function(_, name, cmds)
    construct_group(name, cmds)
  end,
  __call = function(_, ...)
    local wrap = { ... }

    if type(wrap[1]) == "string" then
      construct_group(wrap[1], wrap[2])
      return
    end

    for name, opts in pairs(wrap[1]) do
      construct_group(name, opts)
    end
  end,
})

edn.au = au
edn.aug = aug

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

set.tabstop = 4
set.shiftwidth = 4
set.softtabstop = 4
set.expandtab = true
set.showmatch = true
set.ignorecase = true
set.hlsearch = true
set.incsearch = true
set.autoindent = true
set.number = true
set.syntax = 'on'
set.clipboard = 'unnamedplus'
set.cursorline = true
set.splitright = true
set.splitbelow = true
set.showtabline = 2

rt.setup({
    server = {
        on_attach = function(_, bufnr)
            vim.keymap.set("n", "<C-space", rt.hover_actions.hover_actions, {buffer = bufnr})

            vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr})
        end,
    },
})

local sign = function(opts)
    vim.fn.sign_define(opts.name, {
        texthl = opts.name,
        text = opts.text,
        numhl = ''
    })
end

sign({name = 'DiagnosticSignError', text = ''})
sign({name = 'DiagnosticSignWarn', text = ''})
sign({name = 'DiagnosticSignHint', text = ''})
sign({name = 'DiagnosticSignInfo', text = ''})

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = true,
    underline = true,
    severity_sort = false,
    float = {
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    }
})

-- colorscheme
vim.cmd("colorscheme carbonfox")

-- TODO: add cursorhold diagnostics


-- Completion Plugin Setup
local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },
  -- Installed sources:
  sources = {
    { name = 'path' },                              -- file paths
    { name = 'nvim_lsp', keyword_length = 3 },      -- from language server
    { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
    { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
    { name = 'buffer', keyword_length = 2 },        -- source current buffer
    { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip 
    { name = 'calc'},                               -- source for math calculation
  },
  window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
  },
  formatting = {
      fields = {'menu', 'abbr', 'kind'},
      format = function(entry, item)
          local menu_icon ={
              nvim_lsp = 'λ',
              vsnip = '⋗',
              buffer = 'Ω',
              path = '🖫',
          }
          item.menu = menu_icon[entry.source.name]
          return item
      end,
  },
})

require('nvim-treesitter.configs').setup {
    ensure_installed = { "lua", "rust", "toml" },
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = { enable = true};
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil,
    }
}

require('lsp-colors').setup({
    Error = "#db4b4b",
    Warning = "#e0af68",
    Information = "#0db9d7",
    Hint = "#10B981"
})

require("indent_blankline").setup {
    -- for example, context is off by default, use this to turn it on
    show_current_context = true,
    show_current_context_start = true,
}

require('hlargs').setup()

require('impatient')

require("nvim-tree").setup({
    sort_by = "case_sensitive",
    view = {
        width = 30,
        mappings = {
            list = {
                { key = "CR", action = "tabnew", silent = "true"}
            },
        },
    },
})

-- Tabby tabline
local filename = require("tabby.filename")
require("colors")
local util = require("tabby.util")

local cwd = function()
    return "  " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. " "
end

-- ֍ ֎ 

local line = {
    hl = "TabLineFill",
    layout = "active_wins_at_tail",
    head = {
        { cwd, hl = "EdenTLHead" },
        { "", hl = "EdenTLHeadSep" },
    },
    active_tab = {
        label = function(tabid)
        return {
            "  " .. tabid .. " ",
            hl = "EdenTLActive",
        }
    end,
    left_sep = { "", hl = "EdenTLActiveSep" },
    right_sep = { "", hl = "EdenTLActiveSep" },
  },
  inactive_tab = {
    label = function(tabid)
      return {
        "  " .. tabid .. " ",
        hl = "EdenTLBoldLine",
      }
    end,
    left_sep = { "", hl = "EdenTLLineSep" },
    right_sep = { "", hl = "EdenTLLineSep" },
  },
  top_win = {
    label = function(winid)
      return {
        "  " .. filename.unique(winid) .. " ",
        hl = "TabLine",
      }
    end,
    left_sep = { "", hl = "EdenTLLineSep" },
    right_sep = { "", hl = "EdenTLLineSep" },
  },
  win = {
    label = function(winid)
      return {
        "  " .. filename.unique(winid) .. " ",
        hl = "TabLine",
      }
    end,
    left_sep = { "", hl = "EdenTLLineSep" },
    right_sep = { "", hl = "EdenTLLineSep" },
  },
  tail = {
    { "", hl = "EdenTLHeadSep" },
    { "  ", hl = "EdenTLHead" },
  },
}

require("tabby").setup({ tabline = line })

local u = require("felutil")
local fmt = string.format

-- "┃", "█", "", "", "", "", "", "", "●"

local get_diag = function(str)
  local diagnostics = vim.diagnostic.get(0, { severity = vim.diagnostic.severity[str] })
  local count = #diagnostics

  return (count > 0) and " " .. count .. " " or ""
end

local function vi_mode_hl()
  return u.vi.colors[vim.fn.mode()] or "EdenSLViBlack"
end

local function vi_sep_hl()
  return u.vi.sep[vim.fn.mode()] or "EdenSLBlack"
end

local c = {
  vimode = {
    provider = function()
      return string.format(" %s ", u.vi.text[vim.fn.mode()])
    end,
    hl = vi_mode_hl,
    right_sep = { str = " ", hl = vi_sep_hl },
  },
  gitbranch = {
    provider = "git_branch",
    icon = " ",
    hl = "EdenSLGitBranch",
    right_sep = { str = "  ", hl = "EdenSLGitBranch" },
    enabled = function()
      return vim.b.gitsigns_status_dict ~= nil
    end,
  },
  file_type = {
    provider = function()
      return fmt(" %s ", vim.bo.filetype:upper())
    end,
    hl = "EdenSLAlt",
  },
  fileinfo = {
    provider = { name = "file_info", opts = { type = "relative" } },
    hl = "EdenSLAlt",
    left_sep = { str = " ", hl = "EdenSLAltSep" },
    right_sep = { str = " ", hl = "EdenSLAltSep" },
  },
  file_enc = {
    provider = function()
      local os = u.icons[vim.bo.fileformat] or ""
      return fmt(" %s %s ", os, vim.bo.fileencoding)
    end,
    hl = "StatusLine",
    left_sep = { str = u.icons.left_filled, hl = "EdenSLAltSep" },
  },
  cur_position = {
    provider = function()
      -- TODO: What about 4+ diget line numbers?
      return fmt(" %3d:%-2d ", unpack(vim.api.nvim_win_get_cursor(0)))
    end,
    hl = vi_mode_hl,
    left_sep = { str = u.icons.left_filled, hl = vi_sep_hl },
  },
  cur_percent = {
    provider = function()
      return " " .. require("feline.providers.cursor").line_percentage() .. "  "
    end,
    hl = vi_mode_hl,
    left_sep = { str = u.icons.left, hl = vi_mode_hl },
  },
  default = { -- needed to pass the parent StatusLine hl group to right hand side
    provider = "",
    hl = "StatusLine",
  },
  lsp_status = {
    provider = function()
      return require("lsp-status").status()
    end,
    hl = "EdenSLStatus",
    left_sep = { str = "", hl = "EdenSLStatusBg", always_visible = true },
    right_sep = { str = "", hl = "EdenSLErrorStatus", always_visible = true },
  },
  lsp_error = {
    provider = function()
      return get_diag("ERROR")
    end,
    hl = "EdenSLError",
    right_sep = { str = "", hl = "EdenSLWarnError", always_visible = true },
  },
  lsp_warn = {
    provider = function()
      return get_diag("WARN")
    end,
    hl = "EdenSLWarn",
    right_sep = { str = "", hl = "EdenSLInfoWarn", always_visible = true },
  },
  lsp_info = {
    provider = function()
      return get_diag("INFO")
    end,
    hl = "EdenSLInfo",
    right_sep = { str = "", hl = "EdenSLHintInfo", always_visible = true },
  },
  lsp_hint = {
    provider = function()
      return get_diag("HINT")
    end,
    hl = "EdenSLHint",
    right_sep = { str = "", hl = "EdenSLFtHint", always_visible = true },
  },

  in_fileinfo = {
    provider = "file_info",
    hl = "StatusLine",
  },
  in_position = {
    provider = "position",
    hl = "StatusLine",
  },
}

local active = {
  { -- left
    c.vimode,
    c.gitbranch,
    c.fileinfo,
    c.default, -- must be last
  },
  { -- right
    c.lsp_status,
    c.lsp_error,
    c.lsp_warn,
    c.lsp_info,
    c.lsp_hint,
    c.file_type,
    c.file_enc,
    c.cur_position,
    c.cur_percent,
  },
}

local inactive = {
  { c.in_fileinfo }, -- left
  { c.in_position }, -- right
}

-- -- Define autocmd that generates the highlight groups from the new colorscheme
-- -- Then reset the highlights for feline
-- edn.aug.FelineColorschemeReload = {
--   {
--     { "SessionLoadPost", "ColorScheme" },
--     function()
--       require("eden.modules.ui.feline.colors").gen_highlights()
--       -- This does not look like it is required. If this is called I see the ^^^^^^ that
--       -- seperates the two sides of the bar. Since the entire config uses highlight groups
--       -- all that is required is to redefine them.
--       -- require("feline").reset_highlights()
--     end,
--   },
-- }

require("feline").setup({
  components = { active = active, inactive = inactive },
  highlight_reset_triggers = {},
  force_inactive = {
    filetypes = {
      "NvimTree",
      "packer",
      "dap-repl",
      "dapui_scopes",
      "dapui_stacks",
      "dapui_watches",
      "dapui_repl",
      "LspTrouble",
      "qf",
      "help",
    },
    buftypes = { "terminal" },
    bufnames = {},
  },
  disable = {
    filetypes = {
      "dashboard",
      "startify",
    },
  },
})
