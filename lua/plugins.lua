vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)

    use 'wbthomason/packer.nvim'

    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'
    
    use 'neovim/nvim-lspconfig'
    use 'simrat39/rust-tools.nvim'
    
    use 'hrsh7th/nvim-cmp'
    
    use 'hrsh7th/cmp-nvim-lsp'

    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'hrsh7th/cmp-vsnip'                             
    use 'hrsh7th/cmp-path'                              
    use 'hrsh7th/cmp-buffer'                            
    use 'hrsh7th/vim-vsnip'

    use 'nvim-treesitter/nvim-treesitter'

    use 'puremourning/vimspector'

    use 'voldikss/vim-floaterm'

    use {'nvim-telescope/telescope.nvim', requires = { {'nvim-lua/plenary.nvim'} }}
    use 'kyazdani42/nvim-tree.lua'
    use 'preservim/tagbar'
    use { 'folke/todo-comments.nvim', requires = "nvim-lua/plenary.nvim", config = function () require("todo-comments").setup {} end }
    use 'folke/trouble.nvim'
    use 'folke/lsp-colors.nvim'

    use 'lukas-reineke/indent-blankline.nvim'
    use { 'windwp/nvim-autopairs', config = function() require("nvim-autopairs").setup {} end }
    use 'tpope/vim-surround'
    use 'RRethy/vim-illuminate'
    use { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end }

    use { 'm-demare/hlargs.nvim', requires = { 'nvim-treesitter/nvim-treesitter' } }
    use 'danilamihailov/beacon.nvim'
    use 'kyazdani42/nvim-web-devicons'
    use 'lewis6991/impatient.nvim'

    use 'tpope/vim-fugitive'
    use 'EdenEast/nightfox.nvim'

    use 'nanozuki/tabby.nvim'
    use {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    }

    use 'feline-nvim/feline.nvim'
    use 'nvim-lua/lsp-status.nvim'

    use 'wakatime/vim-wakatime'
end)
