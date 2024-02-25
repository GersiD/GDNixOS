# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.default = "saved";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "Timber"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Mullvad
  services.mullvad-vpn.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure Xserver
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    displayManager = {
      # Enable the GNOME Desktop Environment.
      gdm.enable = true;
      gdm.wayland = true;
      # Enable the KDE Plasma Desktop Environment.
      # sddm.enable = true;
      # Enable automatic login for the user.
      autoLogin = {
        enable = true;
        user = "gd";
      };
      defaultSession = "hyprland";
    };
    # desktopManager.gnome.enable = true;
    # desktopManager.plasma5.enable = true;
    # Enable touchpad support (enabled default in most desktopManager).
    # libinput.enable = true;
  };
  # Many DEs require dconf for some reason
  programs.dconf.enable = true;

# BEGIN HYPRLAND
  programs.hyprland = {
    enable = true;
    enableNvidiaPatches = true;
    xwayland.enable = true;
  };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  hardware = {
    opengl.enable = true;
    nvidia.modesetting.enable = true;
  };
  xdg.portal.enable = true;
# END HYPRLAND

  # Exclude some packages from the GNOME Desktop Environment.
  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    gnome.cheese
    gnome.gnome-music
    gnome.geary
    gnome.tali
    gnome.iagno
    gnome.hitori
    gnome.atomix
  ];
  # Exclude some packages from the KDE Plasma Desktop Environment.
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    konsole
    oxygen
    plasma-browser-integration
    kwrited
  ];
  # Dynamic Triple Buffering For GNOME
  nixpkgs.overlays = [
  (final: prev: {
      gnome = prev.gnome.overrideScope' (gnomeFinal: gnomePrev: {
        mutter = gnomePrev.mutter.overrideAttrs ( old: {
          src = pkgs.fetchgit {
            url = "https://gitlab.gnome.org/vanvugt/mutter.git";
            # GNOME 45: triple-buffering-v4-45
            rev = "0b896518b2028d9c4d6ea44806d093fd33793689";
            sha256 = "sha256-mzNy5GPlB2qkI2KEAErJQzO//uo8yO0kPQUwvGDwR4w=";
          };
        });
      });
    })
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
    (self: super: {
      neovim = super.neovim.override {
        viAlias = true;
        vimAlias = true;
      };
    })
  ];
  # GNOME workaround
  # systemd.services."getty@tty1".enable = false;
  # systemd.services."autov@tty1".enable = false;
  # For systray icons
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  programs.zsh = {
    enable = true;
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    shellAliases = {
      ll = "ls -l";
      update = "sudo /etc/nixos/rebuild_switch.sh";
    };
  };
  users.defaultUserShell = pkgs.zsh;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gd = {
    isNormalUser = true;
    description = "gd";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      ripgrep
      firefox
      alacritty
      gnome.gnome-tweaks
      gradience
      kate
      btop
      nodejs
      lazygit
      mullvad-vpn
      deluge
      vlc
      oh-my-zsh
      zsh-powerlevel10k
      zsh-autosuggestions
      zoxide
      rustup
      clang
      llvmPackages_16.bintools
      tmux
      unzip
      neofetch
    ];
    shell = pkgs.zsh;
  };

  # Fonts
  fonts.packages = with pkgs; [
     nerdfonts
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     zsh
     waybar
     hyprland
     fzf
     neovim-nightly
     git
     stow
     gnumake
     gnomeExtensions.appindicator
     gnomeExtensions.just-perfection
     gnomeExtensions.dash-to-dock
     gnomeExtensions.arc-menu
  ];
  environment.shells = with pkgs; [
    zsh
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
