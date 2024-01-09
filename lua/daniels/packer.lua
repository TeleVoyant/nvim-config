-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]


-- --------------------------------- --
-- --------------------------------- --
-- A TOTAL OF 26 PLUGINS! SHEEEEESH! --
-- --------------------------------- --
-- --------------------------------- --
return require('packer').startup(function(use)
    ------------------------------
    -- Packer can manage itself --
    use ('wbthomason/packer.nvim')
    ------------------------------
    ------------------------------


    -- the perfect Rose-pine colors --
    use({
        'rose-pine/neovim',
        as = 'rose-pine',
        config = function()
            vim.cmd('colorscheme rose-pine')
        end
    })

    -- the only finder you will ever need --
    use ({
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        -- or                            , branch = '0.1.x',
        requires = {
            { 'nvim-lua/plenary.nvim' },
            { 'BurntSushi/ripgrep' },
            { 'sharkdp/fd'},
        }
    })

    ------------------------------------------------------
    ------------------- additional plugins ---------------
    -- ------------------------------------------------ --
    -- -------------------------- --
    -- beautiful icons every where --
    use ('nvim-tree/nvim-web-devicons')
    -- -------------------------- --
    -- status bar plugin (bottom) --
    use ({
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true } -- optional
    })
    -- -------------------------- --
    -- file explorer plugin --
    use ({
        'nvim-tree/nvim-tree.lua',
        requires = { 'nvim-tree/nvim-web-devicons' }, -- optional
    })
    -- --------------------------- --
    -- navigation bar plugin (top) --
    use ({
        'romgrk/barbar.nvim',
        requires = { 'nvim-tree/nvim-web-devicons' }, -- optional
    })
    -- --------------------------- --

    -- -------------------------------------- --
    -- colors (+tailwindcss) highlight plugin --
    use ('brenoprata10/nvim-highlight-colors')
    -- ------------------- --
    -- color picker plugin --
    use ({
        "ziontee113/color-picker.nvim",
        config = function()
            require("color-picker")
        end,
    })
    -- ------------------ --
    -- ------------------ --

    -- ------------------------------------- --
    -- tree blame for neovim, very important --
    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    -- tree blame playground --
    use('nvim-treesitter/playground')
    -- ------------------------------------- --

    -- ----------------------------------- --
    -- language server protocol for neovim --
    use({
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        requires = {
            -- Autocompletion
            { 'hrsh7th/nvim-cmp' }, -- Required
            { 'onsails/lspkind.nvim' }, -- Completion Icons, optional (necessary)
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            -- LSP Support
            { 'neovim/nvim-lspconfig' }, -- Required
            { 'williamboman/mason.nvim' }, -- Optional (necessary)
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional (necessary)
            -- Snippets
            { 'L3MON4D3/LuaSnip' }, -- Required
        }
    })
    -- ----------------------------------- --
    -- pretty list showing all the troubles --
    use ({
        'folke/trouble.nvim',
        requires = { "nvim-tree/nvim-web-devicons" },
    })
    -- --------------------------- --
    -- ----------------------------------- --

    -- "GET OVER HEEEREE" switch btn files as fast as lightning --
    use('theprimeagen/harpoon')
    -- undo tree implementation for neovim --
    use('mbbill/undotree')
    -- forgot what this does... oooh remembered! its for Git in neovim :) --
    use('tpope/vim-fugitive')
    -- for all the indents and space highlightings --
    use('lukas-reineke/indent-blankline.nvim')
    -- for comments --
    use ({
        'numToStr/Comment.nvim',
        config = function () require('Comment').setup {} end
    })
    -- Surround selections, stylishly --
    use({
        'kylechui/nvim-surround',
        config = function() require("nvim-surround").setup() end
    })
    -- Cloak sensitive files from prying eyes
    use('laytan/cloak.nvim')


    -- Obsidian -- a simple, markdown-based notes app
    use({
        "epwalsh/obsidian.nvim",
        tag = "*",  -- recommended, use latest release instead of latest commit
        requires = {
            -- Required.
            "nvim-lua/plenary.nvim",
            -- Optional
            "hrsh7th/nvim-cmp",               -- for auto-completion
            "nvim-telescope/telescope.nvim",  -- for quick-switch functionality
        },
        config = function()
            require("obsidian").setup({
                workspaces = {
                    {
                        name = "personal",
                        path = "~/vaults/personal",
                    },
                    {
                        name = "work",
                        path = "~/vaults/work",
                    },
                },
            })
        end,
    })

    -- for openscad programing --
    use ({
    	'salkin-mada/openscad.nvim',
    	config = function() require('openscad') vim.g.openscad_load_snippets = true end,
    	requires = { 'L3MON4D3/LuaSnip' }
    })

    -- hex editor --
    use ('RaafatTurki/hex.nvim')

    -- ----------------------- --
    -- FOR DOCUMENTATIONS ONLY --
    -- for markdown processing --
    use({
        'iamcco/markdown-preview.nvim',
        run = function() vim.fn["mkdp#util#install"]() end,
    })
    use({ 
        'iamcco/markdown-preview.nvim', 
        run = "cd app && npm install", 
        setup = function() vim.g.mkdp_filetypes = { "markdown" } end, 
        ft = { "markdown" }, 
    })
    -- ----------------------- --

end)

