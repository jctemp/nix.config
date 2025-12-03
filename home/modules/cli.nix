# home/modules/cli.nix
{ pkgs, ... }:
{
  # ===============================================================
  #       SHELL CONFIGURATION
  # ===============================================================
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      system-rebuild = "sudo nixos-rebuild switch --flake .#desktop";
      home-rebuild = "home-manager switch --flake .#zen";

      # Color support
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";

      # Modified commands
      df = "df -h";
      du = "du -h";
      free = "free -h";
      less = "less -i";
      mkdir = "mkdir -pv";
      ping = "ping -c 3";
      ".." = "cd ..";
    };
    bashrcExtra = ''
      export HISTSIZE=10000
      export HISTFILESIZE=20000
      export HISTCONTROL=ignoreboth:erasedups
    '';
  };

  # ===============================================================
  #       EDITOR
  # ===============================================================
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "ayu_dark";
      editor = {
        line-number = "absolute";
        true-color = true;
        rulers = [
          80
          120
        ];
        color-modes = true;
        end-of-line-diagnostics = "hint";
        auto-pairs = true;
        auto-completion = true;
        auto-format = true;

        indent-guides = {
          render = true;
          character = "|";
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        search = {
          smart-case = true;
          wrap-around = true;
        };

        file-picker = {
          hidden = false;
          follow-symlinks = true;
          git-ignore = true;
        };
      };
    };
  };

  # ===============================================================
  #       TERMINAL MULTIPLEXER
  # ===============================================================
  programs.zellij = {
    enable = true;
    enableBashIntegration = false;
    settings = {
      simplified_ui = true;
      show_startup_tips = false;
      copy_command = "${pkgs.xclip}/bin/xclip -sel clipboard";
    };
  };

  # ===============================================================
  #       GIT
  # ===============================================================
  programs.git = {
    enable = true;
  };

  programs.gitui = {
    enable = true;
    keyConfig = ''
      (
          move_left: Some(( code: Char('h'), modifiers: "")),
          move_right: Some(( code: Char('l'), modifiers: "")),
          move_up: Some(( code: Char('k'), modifiers: "")),
          move_down: Some(( code: Char('j'), modifiers: "")),
          stash_open: Some(( code: Char('l'), modifiers: "")),
          open_help: Some(( code: F(1), modifiers: "")),
          status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),
      )
    '';
  };

  # ===============================================================
  #       SHELL TOOLS
  # ===============================================================
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[x](bold red)";
        vimcmd_symbol = "[<](bold green)";
      };
      git_status = {
        ahead = ">";
        behind = "<";
        diverged = "<>";
        renamed = "r";
        deleted = "x";
      };
      directory = {
        read_only = " ro";
      };
      git_branch = {
        symbol = "git ";
      };
      nix_shell = {
        symbol = "nix ";
      };
      os.symbols = {
        NixOS = "nix ";
      };
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
    config = {
      warn_timeout = "1h";
      load_dotenv = true;
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--border"
    ];
  };

  # ===============================================================
  #       CLI PACKAGES
  # ===============================================================
  home.packages = with pkgs; [
    # Development tools
    gh
    fzf
    fd
    ripgrep
    bat
    eza
    zoxide

    # Spell checking
    aspell
    aspellDicts.en
    aspellDicts.de
  ];

  # ===============================================================
  #       XDG CONFIGURATION
  # ===============================================================
  xdg = {
    enable = true;
    configFile = {
      # Global gitignore
      "git/ignore".text = ''
        # Editor files
        .vscode/
        .idea/
        *.swp
        *.swo
        *~

        # OS files
        .DS_Store
        Thumbs.db

        # Development environment
        .direnv/
        .envrc.local

        # Logs and temporary files
        *.log
        *.tmp
        *.temp
      '';

      # Helix ignore patterns
      "helix/ignore".text = ''
        .git/
        node_modules/
        target/
        .direnv/
        result
        result-*
        *.tmp
        *.log
      '';
    };
  };

  # ===============================================================
  #       ENVIRONMENT VARIABLES
  # ===============================================================
  home.sessionVariables = {
    PAGER = "less";
    LESS = "-R";
  };
}
