return {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = { 
                "c", 
                "lua", 
                "vim", 
                "bash",
                "python",
                "javascript",
                "typescript",
                "yaml",

                "json",
                "dockerfile",
                "hcl",         
                "toml",        
                "ini",        

                "html",        
                "css",         
                "regex",       
                "jq",          
                "xml",       

                "markdown", 
                "markdown_inline",

                "sql"
            },
            sync_install = false,
            auto_install = true,
            ignore_install = {},

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        })
    end,
}

