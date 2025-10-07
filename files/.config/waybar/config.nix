{
  mainBar = {
    layer = "top"; # top | bottom
    # position = "bottom"; # Waybar position (top|bottom|left|right)
    # height = 48; # Waybar height (to be removed for auto height)
    # width = 1280; # Waybar width
    spacing = 8; # Gaps between modules (4px)

    # Choose the order of the modules
    modules-left = ["hyprland/workspaces"];
    modules-center = [];
    modules-right = ["network" "pulseaudio" "cpu" "memory" "backlight" "battery" "clock"];

    # Hyprland
    "hyprland/workspaces" = {
      format = "{name}";
      persistent-workspaces = {"*" = ["1-AV" "2-Main" "3-Docs" "4-Laptop"];};
      persistent-only = true; # show only the persistent ones
      show-special = false; # hide special workspaces
      all-outputs = false; # (optional) only show for the current output
    };

    clock = {
      # timezone = "America/New_York";
      today-format = "<span color='#ff6699'><b>{}</b></span>";
      tooltip-format = ''
        <big>{:%Y %B}</big>
        <tt><small>{calendar}</small></tt>'';
      locale = "";
      interval = 1;
      format = "{:%Y-%m-%d %H:%M:%S}";
      format-alt = "{:%H:%M:%S}";
    };

    cpu = {
      interval = 2;
      format = "{icon0}{icon1}{icon2}{icon3}{icon4}{icon5}{icon6}{icon7}";
      format-icons = [
        "▁"
        "▂"
        "▃"
        "▄"
        "▅"
        ''<span color="#e6e600">▆</span>''
        ''<span color="#f1c40f">▇</span>''
        ''<span color="#f53c3c">█</span>''
      ];
      tooltip = false;
    };

    memory = {
      interval = 10;
      format = "{}% ";
    };

    backlight = {
      device = "intel_backlight";
      format = "{percent}% {icon}";
      format-icons = ["" "" "" "" "" "" "" "" ""];
      smooth-scrolling-threshold = 0.9;
    };

    battery = {
      states = {
        warning = 30;
        critical = 15;
      };
      format = "{capacity}% {icon}";
      format-charging = "{capacity}% ";
      format-plugged = "{capacity}% ";
      format-alt = "{time} {icon}";
      format-icons = ["" "" "" "" ""];
    };

    network = {
      format-wifi = "{essid} ({signalStrength}%) ";
      format-ethernet = "{ipaddr}/{cidr} ";
      tooltip-format = "{ifname} via {gwaddr} ";
      format-linked = "{ifname} (No IP) ";
      format-disconnected = "Disconnected ⚠";
      format-alt = "{ifname}: {ipaddr}/{cidr}";
    };

    pulseaudio = {
      format = "{volume}% {icon} {format_source}";
      format-bluetooth = "{volume}% {icon} {format_source}";
      format-bluetooth-muted = "🔇 {icon} {format_source}";
      format-muted = "🔇 {format_source}";
      format-source = "{volume}% ";
      format-source-muted = "";
      format-icons = {
        headphone = "";
        hands-free = "";
        headset = "";
        phone = "";
        portable = "";
        car = "";
        default = ["" "" ""];
      };
      on-click = "pwvucontrol";
    };
  };
}
