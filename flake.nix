{
  description = "svzer's super sweet neovim config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    vim-extra-plugins.url = "github:m15a/nixpkgs-vim-extra-plugins";
    neovim = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim-lspconfig = { url = "github:neovim/nvim-lspconfig"; flake = false; };
    nvim-cmp = { url = "github:hrsh7th/nvim-cmp"; flake = false; };
    cmp-nvim-lsp = { url = "github:hrsh7th/cmp-nvim-lsp"; flake = false; };
    cmp-nvim-lua = { url = "github:hrsh7th/cmp-nvim-lua"; flake = false; };
    cmp-path = { url = "github:hrsh7th/cmp-path"; flake = false; };
    cmp-buffer = { url = "github:hrsh7th/cmp-buffer"; flake = false; };
    cmp-cmdline = { url = "github:hrsh7th/cmp-cmdline"; flake = false; };
    cmp-under-comparator = { url = "github:lukas-reineke/cmp-under-comparator"; flake = false; };
    cmp_luasnip = { url = "github:saadparwaiz1/cmp_luasnip"; flake = false; };
    luasnip = { url = "github:l3mon4d3/luasnip"; flake = false; };
    nvim-treesitter = { url = "github:nvim-treesitter/nvim-treesitter"; flake = false; };
    nvim-treesitter-context = { url = "github:nvim-treesitter/nvim-treesitter-context"; flake = false; };
    telescope-nvim = { url = "github:nvim-telescope/telescope.nvim"; flake = false; };
    plenary-nvim = { url = "github:nvim-lua/plenary.nvim"; flake = false; };
    telescope-fzf-native-nvim = { url = "github:nvim-telescope/telescope-fzf-native.nvim"; flake = false; };
    telescope-file-browser-nvim = { url = "github:nvim-telescope/telescope-file-browser.nvim"; flake = false; };
    comment-nvim = { url = "github:numtostr/comment.nvim"; flake = false; };
    vim-easy-align = { url = "github:junegunn/vim-easy-align"; flake = false; };
    vim-surround = { url = "github:tpope/vim-surround"; flake = false; };
    vim-repeat = { url = "github:tpope/vim-repeat"; flake = false; };
    leap-nvim = { url = "github:ggandor/leap.nvim"; flake = false; };
    trouble-nvim = { url = "github:folke/trouble.nvim"; flake = false; };
    nvim-tree-lua = { url = "github:kyazdani42/nvim-tree.lua"; flake = false; };
    nvim-colorizer-lua = { url = "github:norcalli/nvim-colorizer.lua"; flake = false; };
    vim-startuptime = { url = "github:dstein64/vim-startuptime"; flake = false; };
    matchparen-nvim = { url = "github:monkoose/matchparen.nvim"; flake = false; };
    nvim-notify = { url = "github:rcarriga/nvim-notify"; flake = false; };
    fidget-nvim = { url = "github:j-hui/fidget.nvim"; flake = false; };
    lsp_lines-nvim = { url = "sourcehut:~whynothugo/lsp_lines.nvim"; flake = false; };
    nvim-web-devicons = { url = "github:kyazdani42/nvim-web-devicons"; flake = false; };
  };

  outputs = { self, nixpkgs, vim-extra-plugins, neovim, ... }@inputs:
  let
    system = "x86_64-linux";

    plugins = [
      "nvim-lspconfig"
      "nvim-cmp"
      "cmp-nvim-lsp"
      "cmp-nvim-lua"
      "cmp-path"
      "cmp-buffer"
      "cmp-cmdline"
      "cmp-under-comparator"
      "cmp_luasnip"
      "luasnip"
      "nvim-treesitter"
      "nvim-treesitter-context"
      "telescope-nvim"
      "plenary-nvim"
      "telescope-fzf-native-nvim"
      "telescope-file-browser-nvim"
      "comment-nvim"
      "vim-easy-align"
      "vim-surround"
      "vim-repeat"
      "leap-nvim"
      "trouble-nvim"
      "nvim-tree-lua"
      "nvim-colorizer-lua"
      "vim-startuptime"
      "matchparen-nvim"
      "nvim-notify"
      "fidget-nvim"
      "lsp_lines-nvim"
      "nvim-web-devicons"
    ];

    vimExtraPluginsOverlay = vim-extra-plugins.overlays.default;

    neovimOverlay = final: prev: {
      neovim-nightly = neovim.packages.${prev.system}.neovim;
    };

    pluginsOverlay = lib.buildPluginOverlay;

    pkgs = lib.mkPkgs { 
      inherit nixpkgs;
      overlays = [
        vimExtraPluginsOverlay
        neovimOverlay
        pluginsOverlay
      ];
    };

    lib = import ./lib { inherit pkgs inputs plugins; };

    mkNeovimPkg = pkgs: 
      lib.neovimBuilder {
        inherit pkgs;
        config = {
          vim.viAlias = true;
          vim.lsp.enable = true;
          vim.treesitter.enable = true;
        };
      };

  in {
    devShells = lib.withDefaultSystems
      (sys: {
        default = pkgs.mkShell {
          buildInputs = [self.packages.${sys}.neovim-svzer];
        };
      });

    overlay = final: prev: {
      neovim-svzer = self.packages.${prev.system}.neovim-svzer;
    };

    packages = lib.withDefaultSystems 
      (sys: rec {
        default = neovim-svzer;
        neovim-svzer = mkNeovimPkg pkgs.${sys};
      });
  };
}
