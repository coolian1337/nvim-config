
vim.opt.completeopt = {'menuone', 'noselect', 'noinsert'}
vim.opt.shortmess = vim.opt.shortmess + { c = true }
vim.api.nvim_set_option('updatetime', 300)

vim.cmd([[
set signcolumn=yes
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

vim.cmd{[[
let g:vimspector_sidebar_width = 85
let g:vimspector_bottombar_height = 5
let g:vimspector_terminal_maxwidth = 70
]]}
