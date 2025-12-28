{ config, pkgs, ... }:

{
  # Enable Neovim with LazyVim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Install additional packages that LazyVim commonly uses
    extraPackages = with pkgs; [
      # Runtime environments (needed by Mason and various plugins)
      nodejs
      python3
      php83
      lua5_1      # Required by rest.nvim
      luarocks
      go

      # Language servers
      lua-language-server
      nil # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.bash-language-server
      pyright
      rust-analyzer

      # PHP Language Servers
      nodePackages.intelephense
      phpactor

      # Docker & DevOps Language Servers
      docker-compose-language-service
      dockerfile-language-server
      yaml-language-server
      terraform-ls
      nodePackages.vscode-langservers-extracted # HTML, CSS, JSON, ESLint
      helm-ls

      # Formatters
      stylua
      nixpkgs-fmt
      nodePackages.prettier
      black

      # PHP Formatters & Tools
      php83Packages.composer

      # YAML/Docker/DevOps Formatters
      yamlfmt
      yamllint
      hadolint # Dockerfile linter
      terraform
      ansible-lint

      # Linters
      selene

      # Tools
      ripgrep
      fd
      gcc
      gnumake
      unzip
      wget
      curl
      tree-sitter
      git
      lazygit
      lazydocker

      # Docker tools
      docker-compose

      # Kubernetes tools
      kubectl
      kubernetes-helm
      k9s

      # JSON/YAML tools
      jq
      yq-go

      # Clipboard support for Wayland
      wl-clipboard

      # File management (for Snacks.explorer trash support)
      trash-cli
    ];
  };

  # Create LazyVim configuration directory structure
  xdg.configFile = {
    # LazyVim starter config
    "nvim/init.lua".text = ''
      -- Bootstrap lazy.nvim
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
          vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
          }, true, {})
          vim.fn.getchar()
          os.exit(1)
        end
      end
      vim.opt.rtp:prepend(lazypath)

      -- Make sure to setup `mapleader` and `maplocalleader` before
      -- loading lazy.nvim so that mappings are correct.
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"

      -- Setup lazy.nvim
      require("lazy").setup({
        spec = {
          -- Import LazyVim and its plugins
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          -- Import/override with your plugins
          { import = "plugins" },
        },
        defaults = {
          lazy = false,
          version = false, -- always use the latest git commit
        },
        install = { colorscheme = { "tokyonight", "habamax" } },
        checker = { enabled = true }, -- automatically check for plugin updates
        performance = {
          rtp = {
            -- disable some rtp plugins
            disabled_plugins = {
              "gzip",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
      })
    '';

    # Basic options
    "nvim/lua/config/options.lua".text = ''
      -- Options are automatically loaded before lazy.nvim startup
      -- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

      local opt = vim.opt

      opt.relativenumber = true -- Relative line numbers
      opt.clipboard = "unnamedplus" -- Sync with system clipboard
      opt.wrap = false -- Disable line wrap
    '';

    # Keymaps
    "nvim/lua/config/keymaps.lua".text = ''
      -- Keymaps are automatically loaded on the VeryLazy event
      -- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

      local map = vim.keymap.set

      -- Better escape using jk in insert mode
      map("i", "jk", "<ESC>")
    '';

    # Autocmds
    "nvim/lua/config/autocmds.lua".text = ''
      -- Autocmds are automatically loaded on the VeryLazy event
      -- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
    '';

    # LazyVim core configuration (colorscheme, etc.)
    "nvim/lua/plugins/core.lua".text = ''
      return {
        {
          "LazyVim/LazyVim",
          opts = {
            colorscheme = "tokyonight",
          },
        },
      }
    '';

    # Treesitter configuration with all languages
    "nvim/lua/plugins/treesitter.lua".text = ''
      return {
        {
          "nvim-treesitter/nvim-treesitter",
          opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
              -- Web & DevOps
              "php",
              "phpdoc",
              "javascript",
              "typescript",
              "html",
              "css",
              "json",
              "yaml",
              "toml",

              -- Docker & Infrastructure
              "dockerfile",
              "terraform",

              -- Shell & Config
              "bash",
              "lua",
              "nix",
              "vim",

              -- SQL
              "sql",

              -- Markdown & Docs
              "markdown",
              "markdown_inline",
            })
          end,
        },
      }
    '';

    # Disable Mason auto-installation (we use Nix for all LSPs/tools)
    "nvim/lua/plugins/mason.lua".text = ''
      return {
        {
          "mason-org/mason.nvim",
          opts = {
            -- Mason is still useful for its UI, but we don't need it to install anything
            -- since all tools are provided via Nix extraPackages
          },
        },
        {
          "mason-org/mason-lspconfig.nvim",
          opts = {
            -- Disable automatic installation - all LSPs provided via Nix
            automatic_installation = false,
          },
        },
      }
    '';

    # LSP configuration for PHP, Docker, Ansible, etc.
    # All LSPs are provided via Nix, so mason = false for each
    "nvim/lua/plugins/lsp.lua".text = ''
      return {
        {
          "neovim/nvim-lspconfig",
          opts = {
            servers = {
              -- PHP Language Server
              intelephense = {
                mason = false,
                settings = {
                  intelephense = {
                    files = {
                      maxSize = 5000000,
                    },
                    format = {
                      braces = "k&r",
                    },
                  },
                },
              },

              -- Phpactor (alternative PHP LSP)
              phpactor = { mason = false },

              -- Docker
              dockerls = { mason = false },
              docker_compose_language_service = { mason = false },

              -- YAML
              yamlls = {
                mason = false,
                settings = {
                  yaml = {
                    schemas = {
                      ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                      ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/docker-compose*.yml",
                      kubernetes = "/*.yaml",
                    },
                  },
                },
              },

              -- Terraform
              terraformls = { mason = false },

              -- JSON
              jsonls = { mason = false },

              -- HTML/CSS
              html = { mason = false },
              cssls = { mason = false },

              -- Bash
              bashls = { mason = false },

              -- Nix
              nil_ls = { mason = false },
            },
          },
        },
      }
    '';

    # PHP specific plugins
    "nvim/lua/plugins/php.lua".text = ''
      return {
        -- Laravel.nvim for Laravel development
        {
          "adalessa/laravel.nvim",
          dependencies = {
            "nvim-telescope/telescope.nvim",
            "tpope/vim-dotenv",
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
          },
          cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
          keys = {
            { "<leader>la", ":Laravel artisan<cr>", desc = "Laravel artisan" },
            { "<leader>lr", ":Laravel routes<cr>", desc = "Laravel routes" },
            { "<leader>lm", ":Laravel related<cr>", desc = "Laravel related" },
          },
          event = { "VeryLazy" },
          opts = {
            features = {
              route_info = { enable = true },
              model_info = { enable = true },
            },
            ui = {
              default = "telescope",
            },
          },
        },

        -- PHP namespace support
        {
          "gbprod/phpactor.nvim",
          dependencies = {
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
          },
          keys = {
            { "<leader>pm", ":PhpactorContextMenu<cr>", desc = "Phpactor context menu" },
            { "<leader>pn", ":PhpactorClassNew<cr>", desc = "Phpactor new class" },
          },
          opts = {},
        },

        -- PHP refactoring tools
        {
          "phpactor/phpactor",
          build = "composer install --no-dev -o",
          ft = "php",
          keys = {
            { "<leader>pcc", ":PhpactorCopyClassName<cr>", desc = "Copy class name" },
            { "<leader>pcs", ":PhpactorImportClass<cr>", desc = "Import class" },
          },
        },
      }
    '';

    # DevOps and Docker plugins
    "nvim/lua/plugins/devops.lua".text = ''
      return {
        -- Dockerfile syntax
        {
          "ekalinin/Dockerfile.vim",
          ft = "dockerfile",
        },

        -- Ansible syntax
        {
          "pearofducks/ansible-vim",
          ft = { "yaml.ansible", "ansible" },
        },

        -- Terraform
        {
          "hashivim/vim-terraform",
          ft = { "terraform", "hcl" },
          config = function()
            vim.g.terraform_fmt_on_save = 1
            vim.g.terraform_align = 1
          end,
        },

        -- YAML folding
        {
          "pedrohdz/vim-yaml-folds",
          ft = "yaml",
        },

        -- Kubernetes YAML support
        {
          "towolf/vim-helm",
          ft = "helm",
        },
      }
    '';

    # Debugging configuration (DAP)
    # NOTE: For PHP debugging, you need to manually install vscode-php-debug:
    #   1. npm install -g @vscode/php-debug (installs to ~/.npm-global or similar)
    #   2. Or clone https://github.com/xdebug/vscode-php-debug and run: npm install && npm run build
    #   3. Update the php_debug_adapter_path below to point to phpDebug.js
    "nvim/lua/plugins/dap.lua".text = ''
      return {
        {
          "mfussenegger/nvim-dap",
          dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",
          },
          keys = {
            { "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle Breakpoint" },
            { "<leader>dc", "<cmd>DapContinue<cr>", desc = "Continue" },
            { "<leader>di", "<cmd>DapStepInto<cr>", desc = "Step Into" },
            { "<leader>do", "<cmd>DapStepOver<cr>", desc = "Step Over" },
            { "<leader>dO", "<cmd>DapStepOut<cr>", desc = "Step Out" },
            { "<leader>dr", "<cmd>DapToggleRepl<cr>", desc = "Toggle REPL" },
            { "<leader>du", "<cmd>lua require('dapui').toggle()<cr>", desc = "Toggle DAP UI" },
          },
          config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup()

            -- PHP (Xdebug) configuration
            -- Try common installation paths for php-debug-adapter
            local php_debug_paths = {
              vim.fn.expand("~/.vscode-php-debug/out/phpDebug.js"),
              vim.fn.expand("~/.local/share/vscode-php-debug/out/phpDebug.js"),
              vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js",
              vim.fn.expand("~/.npm-global/lib/node_modules/@vscode/php-debug/out/phpDebug.js"),
            }

            local php_debug_adapter_path = nil
            for _, path in ipairs(php_debug_paths) do
              if vim.fn.filereadable(path) == 1 then
                php_debug_adapter_path = path
                break
              end
            end

            if php_debug_adapter_path then
              dap.adapters.php = {
                type = "executable",
                command = "node",
                args = { php_debug_adapter_path },
              }

              dap.configurations.php = {
                {
                  type = "php",
                  request = "launch",
                  name = "Listen for Xdebug",
                  port = 9003,
                  log = true,
                  pathMappings = {
                    ["/var/www/html"] = "''${workspaceFolder}",
                  },
                },
              }
            else
              vim.notify(
                "PHP debug adapter not found. Install vscode-php-debug manually.",
                vim.log.levels.WARN
              )
            end

            -- Auto open/close DAP UI
            dap.listeners.after.event_initialized["dapui_config"] = function()
              dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
              dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
              dapui.close()
            end
          end,
        },
      }
    '';

    # Additional useful plugins
    "nvim/lua/plugins/extras.lua".text = ''
      return {
        -- Git integration
        {
          "tpope/vim-fugitive",
          cmd = { "Git", "G" },
        },

        -- NOTE: Comment.nvim removed - Neovim 0.10+ has native gc/gcc commenting
        -- NOTE: nvim-autopairs removed - LazyVim includes mini.pairs by default

        -- Surround
        {
          "kylechui/nvim-surround",
          event = "VeryLazy",
          opts = {},
        },

        -- Todo comments
        {
          "folke/todo-comments.nvim",
          dependencies = { "nvim-lua/plenary.nvim" },
          opts = {},
        },

        -- Better quickfix
        {
          "kevinhwang91/nvim-bqf",
          ft = "qf",
        },

        -- REST client (useful for testing Laravel APIs)
        {
          "rest-nvim/rest.nvim",
          ft = "http",
          keys = {
            { "<leader>rr", "<cmd>Rest run<cr>", desc = "Run request" },
            { "<leader>rl", "<cmd>Rest last<cr>", desc = "Run last request" },
          },
          config = function()
            -- rest.nvim v3 configuration
            vim.g.rest_nvim = {
              request = {
                skip_ssl_verification = false,
                hooks = {
                  encode_url = true,
                  user_agent = "rest.nvim",
                  set_content_type = true,
                },
              },
              response = {
                hooks = {
                  decode_url = true,
                  format = true,
                },
              },
              highlight = {
                enable = true,
                timeout = 750,
              },
            }
          end,
        },

        -- Database client
        {
          "kristijanhusak/vim-dadbod-ui",
          dependencies = {
            "tpope/vim-dadbod",
            "kristijanhusak/vim-dadbod-completion",
          },
          cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
          keys = {
            { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Toggle DBUI" },
          },
        },
      }
    '';
  };
}
