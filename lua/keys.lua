
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        if opts.desc then
            opts.desc = "keymaps.lua: " .. opts.desc
        end
        options = vim.tbl_extend('force', options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

vim.g.mapleader = ' '

-- tree
map('n', '<leader>tt', '<cmd>NvimTreeToggle<CR>')
map('n', '<leader>tf', '<cmd>NvimTreeFocus<CR>')
map('n', '<leader>ts', '<cmd>NvimTreeFindFile<CR>')
map('n', '<leader>tc', '<cmd>NvimTreeCollapse<CR>')

-- Vimspector
vim.cmd([[
nmap <F9> <cmd>call vimspector#Launch()<cr>
nmap <F5> <cmd>call vimspector#StepOver()<cr>
nmap <F8> <cmd>call vimspector#Reset()<cr>
nmap <F11> <cmd>call vimspector#StepOver()<cr>")
nmap <F12> <cmd>call vimspector#StepOut()<cr>")
nmap <F10> <cmd>call vimspector#StepInto()<cr>")
]])
map('n', "Db", ":call vimspector#ToggleBreakpoint()<cr>")
map('n', "Dw", ":call vimspector#AddWatch()<cr>")
map('n', "De", ":call vimspector#Evaluate()<cr>")


-- Float Term
map('n', "<leader>ft", ":FloatermNew --name=float --height=0.8 --width=0.7 --autoclose=2 zsh <CR> ")
map('n', "t", ":FloatermToggle float<CR>")
map('t', "<Esc>", "<C-\\><C-n>:q<CR>")

map('n', "<F7>", ":TagbarToggle<CR>")

-- telescope
local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files)
map('n', '<leader>fg', builtin.live_grep, {})
map('n', '<leader>fb', builtin.buffers, {})
map('n', '<leader>fh', builtin.help_tags, {})

map('n', '<leader>tn', ':$tabnew<CR>')
map('n', '<leader>tc', ':tabclose<CR>')
map('n', '<leader>to', ':tabonly<CR>')
map('n', '<leader>tp', 'tabp<CR>')
map('n', '<leader>tn', ':tabn<CR>')
map('n', '<leader>tmp', ':-tabmove<CR>')
map('n', '<leader>tmn', ':+tabmove<CR>')

-- move line or visually selected block up/down
map('i', '<A-j>', '<Esc>:m .+1<CR>==gi')
map('i', '<A-k>', '<Esc>:m .-2<CR>==gi')
map('v', '<A-j>', "<Esc>:m '>+1<CR>gv=gv")
map('v', '<A-j>', "<Esc>:m '<-2<CR>gv=gv")

-- move split panes
map('n', '<A-h', '<C-W>H')
map('n', '<A-j', '<C-W>J')
map('n', '<A-k', '<C-W>K')
map('n', '<A-l', '<C-W>L')

-- move between panes
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
