# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 50;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelModules = [ "acpi_backlight=vendor" ];
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;

  nixpkgs.config.allowUnfree = true;  
  nixpkgs.config.permittedInsecurePackages =
    lib.optional (pkgs.obsidian.version == "1.4.16") "electron-25.9.0";

  networking.hostName = "nix-a514"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "ter-v22n";  # "Lat2-Terminus16";
    keyMap = lib.mkForce "uk";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services.thermald.enable = true;
  services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 30;

       #Optional helps save long term battery health
       START_CHARGE_THRESH_BAT0 = 25; # 25 and bellow it starts to charge
       STOP_CHARGE_THRESH_BAT0 = 90; # 90 and above it stops charging

      };
  };

  services.logind = {
    powerKey = "ignore";
    powerKeyLongPress = "poweroff";
    suspendKey = "ignore";
    suspendKeyLongPress = "suspend";
  };

  services.postgresql = {
    enable = true;
    ensureUsers = [
      { name = "stan"; }
    ];
    authentication = "local all all trust\n";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
  };

  services.displayManager.sddm = {
      enable = true;
      theme = "aerial-sddm-theme";
      wayland.enable = true;
    };

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  programs.light.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
    };
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.acpilight.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal
    xdg-desktop-portal-wlr
  ];

  # Configure keymap in X11
  services.xserver.xkb.layout = "gb";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Thunar Config
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # hardware.enableAllFirmware = true;
  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
  services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
    };
  };

  # Make swaylock work?
  security.pam.services.swaylock = {};

  # Virtualisation settings
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
	};
    };
  };
  programs.virt-manager.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      fira-code-nerdfont
      terminus_font
      terminus-nerdfont
    ];
    fontconfig.defaultFonts = {
      monospace = [ "Fira Code Mono" ];
    };
    fontDir.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.stan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "libvirtd" "kvm" "input" "pipewire" "wireplumber" "output" ]; 
    packages = with pkgs; [
      firefox
      tree
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    acpilight
    (callPackage ./aerial-sddm-theme.nix{}).aerial-sddm-theme
    alacritty
    brave
    bruno
    brightnessctl
    btop
    cinnamon.xreader
    discord
    dunst
    fd
    file
    findutils
    flameshot
    fzf
    gccgo
    gedit
    gh
    gimp
    git
    gnome.gvfs
    gnome.gpaste
    go
    gradle
    grim
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-libav
    gst_all_1.gst-vaapi
    gvfs
    hyprland
    jetbrains.idea-ultimate
    kdePackages.kmahjongg
    kitty
    libgcc
    libnotify
    libreoffice
    libsForQt5.phonon
    libsForQt5.libqtav
    libsForQt5.qt5.qtgraphicaleffects
    libvirt
    lshw
    mesa
    neovim
    networkmanagerapplet
    networkmanager_strongswan
    obsidian
    openjdk17-bootstrap
    pamixer
    pavucontrol
    pwvucontrol
    pkg-config
    postgresql
    power-profiles-daemon
    protonup
    qemu
    (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
        qemu-system-x86_64 \
          -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
          "$@"
      '')
    python3
    ripgrep
    rofi-wayland
    rsync
    rustup
    shutter
    skypeforlinux
    slurp
    sqlite
    starship
    steam
    strongswan
    strongswanNM
    swappy
    swaylock
    swtpm
    swww
    tldr
    tree-sitter
    thunderbird
    unzip
    vim
    virt-manager
    vlc
    waybar
    (pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      })
    )
    wget
    winetricks
    wineWowPackages.stable
    wineWowPackages.wayland
    wineWowPackages.waylandFull
    win-virtio
    wl-clipboard
    xfce.thunar
    zip
    zlib
    zlib-ng
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/stan/.steam/root/compatibilitytools.d";
    NIXOS_OZONE_WL = "1";
  };

  programs.bash.blesh.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    lua-language-server
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

