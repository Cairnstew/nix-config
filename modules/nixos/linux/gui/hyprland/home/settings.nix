# See default config here:
# https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.conf
{ pkgs, lib, ... }:

let
  blue-light-filter = ./old-config/blue-light-filter.glsl;
  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    meta.description = ''
      Blue-light filter screenshot script for Hyprland. Directly copies region to clipboard.
    '';
    runtimeInputs = with pkgs; [ grim slurp wl-clipboard ];
    text = ''
      #!/bin/sh
      trap 'hyprshade on ${blue-light-filter}' EXIT
      # Turn off blue light filter
      hyprshade off
      # Take a screenshot of a region and copy it to clipboard
      grim -g "$(slurp -w 0 -b 00000088)" - | wl-copy
    '';
  };
  screenrec = pkgs.writeShellApplication {
    name = "screenrec";
    meta.description = ''
      Blue-light filter screen recording script for Hyprland. Stores videos in ~/Videos.
    '';
    runtimeInputs = with pkgs; [ wl-screenrec slurp ];
    text = ''
      #!/bin/sh
      trap 'hyprshade on ${blue-light-filter}' EXIT
      # Turn off blue light filter
      hyprshade off
      # Grab region and start recording.
      cd
      FN="$HOME/Videos/screenrec-$(date +'%Y%m%d%H%M%S').mp4"
      echo "Selecting and recording ($FN) ... press Ctrl+C to end recording."
      wl-screenrec -g "$(slurp)" -f "$FN"
    '';
  };
in
{
  home.packages = [
    screenrec # Can't bind key, because user must C-c manually to end recording.
  ];

  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";

    source = "~/.hyprland-local.conf";

    bind = [
      "$mainMod, Q, exec, ghostty"

      # Window management
      "$mainMod, C, killactive,"
      "$mainMod, J, togglesplit,"
      "$mainMod, F, fullscreen"
      "$mainMod SHIFT, F, togglefloating"

      # Move focus
      "$mainMod, H, movefocus, l"
      "$mainMod, L, movefocus, r"
      "$mainMod, K, movefocus, u"
      "$mainMod, J, movefocus, d"
      # Move window position
      "$mainMod SHIFT, H, movewindow, l"
      "$mainMod SHIFT, L, movewindow, r"
      "$mainMod SHIFT, K, movewindow, u"
      "$mainMod SHIFT, J, movewindow, d"

      # Workspace management
      # Switch
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      # Move window to workspace
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, left, movecurrentworkspacetomonitor, +1"

      "$mainMod, SPACE, togglespecialworkspace, special"
      "$mainMod SHIFT, SPACE, movetoworkspace, special"

    ];

    # Move/resize windows with mouse
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    # Fn keys
    bindl = [
      # Laptop multimedia keys for volume and LCD brightness
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
      ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      # Requires playerctl
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"

      ", XF86Favorites, exec, rofi -show drun"
      "SHIFT, XF86Favorites, exec, rofi -mode emoji -show emoji"
      ", Print, exec, ${lib.getExe screenshot}"
    ];

    exec-once = [
      "${lib.getExe pkgs.hyprshade} on ${blue-light-filter}"
    ];

    /* COMMENTED OUT:
      # Since this shit changes all the time, I'm managing it by hand in
      # ~/.hyperland-local.conf (see `source` above)
      monitor = [
      # Laptop screen (OLED 2k)
      ",highres,auto,2"
      # Apple Studio Display
      #"DP-6,highres,auto-up,2"
      #"DP-5,disable" # Same as DP-5
      "DP-3,highres,auto-up,2"
      "DP-4,disable" # Same as DP-5
      ];
    */

    general = {
      border_size = 2;
      gaps_out = 5;
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";
      resize_on_border = true;
    };

    decoration = {
      rounding = 10;
      /* shadow = {
        enable = true;
        range = 4;
        render_power = 3;
        color = "rgba(1a1a1aee)";
      }; */
      blur = {
        enabled = true;
        size = 3;
      };
    };

    animations = {
      enabled = true;
      # Default animations
      bezier = [
        "easeOutQuint,0.23,1.0,0.32,1"
        "easeInOutCubic,0.65,0.05,0.36,1"
        "linear,0,0,1,1"
        "almostLinear,0.5,0.5,0.75,1.0"
        "quick,0.15,0.9,1,1"
      ];
      animation = [
        "global, 1, 10, default"
        "border, 1, 5.39, easeOutQuint"
        "windows, 1, 4.79, easeOutQuint"
        "windowsIn, 1, 4.79, easeOutQuint, popin 87%"
        "windowsOut, 1, 4.79, linear, popin 87%"
        "fadeIn, 1, 1.73, almostLinear"
        "fadeOut, 1, 1.46, almostLinear"
        "fade, 1, 3.03, quick"
        "layers, 1, 3.81, easeOutQuint"
        "layersIn, 1, 4, easeOutQuint, fade"
        "layersOut, 1, 5, linear, fade"
        "fadeLayersIn, 1, 1.79, almostLinear"
        "fadeLayersOut, 1, 1.39, almostLinear"
        "workspaces, 1, 1.94, almostLinear, fade"
        "workspacesIn, 1, 1.21, almostLinear, fade"
        "workspacesOut, 1, 1.94, almostLinear, fade"
      ];
    };

    misc = {
      force_default_wallpaper = 2;
    };

    input = {
      follow_mouse = 1;
      natural_scroll = true;
      touchpad.natural_scroll = true;
      kb_options = "ctrl:nocaps";
    };
  };
}
