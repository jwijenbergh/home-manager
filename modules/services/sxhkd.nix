{config, lib, pkgs, ...}:

with lib;

let

  cfg = config.services.sxhkd;

  keybindingsStr = concatStringsSep "\n" (
    mapAttrsToList (hotkey: command:
      optionalString (command != null) ''
        ${hotkey}
          ${command}
      ''
    )
    cfg.keybindings
  );

in

{
  options.services.sxhkd = {
    enable = mkEnableOption "simple X hotkey daemon";

    keybindings = mkOption {
      type = types.attrsOf (types.nullOr types.str);
      default = {};
      description = "An attribute set that assigns hotkeys to commands.";
      example = literalExample ''
        {
          "super + shift + {r,c}" = "i3-msg {restart,reload}";
          "super + {s,w}"         = "i3-msg {stacking,tabbed}";
        }
      '';
    };

    extraConfig = mkOption {
      default = "";
      type = types.lines;
      description = "Additional configuration to add.";
      example = literalExample ''
        super + {_,shift +} {1-9,0}
          i3-msg {workspace,move container to workspace} {1-10}
      '';
    };

    extraPath = mkOption {
      default = "";
      type = types.envVar;
      description = ''
        Additional <envar>PATH</envar> entries to search for commands.
      '';
      example = "/home/some-user/bin:/extra/path/bin";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.sxhkd ];

    xdg.configFile."sxhkd/sxhkdrc".text = concatStringsSep "\n" [
      keybindingsStr
      cfg.extraConfig
    ];

    home.file.".xprofile".text = ''
      "${pkgs.sxhkd}/bin/sxhkd &"
    '';
  };
}
