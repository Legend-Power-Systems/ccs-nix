# Based mostly on https://github.com/gavin4d/nixos-config/blob/7e84411e13559784d8c9c59a583b5787e336106c/modules/home-manager/programs/CCStudio/flake.nix
{
  description = "CodeComposerStudio";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = {self, nixpkgs}: {
    packages.x86_64-linux= {
      CodeComposerStudio =
        with import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          config.packageOverrides = pkgs: {
            steam = pkgs.steam.override {
              extraPkgs = pkgs: with pkgs; [
                libxcrypt-legacy
                python3
                ncurses5
                libusb-compat-0_1
              ];
            };
          };

        };

      stdenv.mkDerivation rec {
        name = "CodeComposerStudio-${version}";
        version = "12.7.0";
        build = "00007";
        src = pkgs.fetchurl {
          url = "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-J1VdearkvK/${version}/CCS${version}.${build}_linux-x64.tar.gz";
          sha256 = "sha256-pbaYBz4XZ0jGt2vo9wzME+3UsBtzOGNMEQcg9ydOvE0=";
        };

        desktopItem = makeDesktopItem {
          type = "Application";
          terminal = false;
          name = "Code Composer Studio";
          exec = "ccs";
          icon = "ccs";
          comment = "Texas Instruments Code Composer Studio";
          desktopName = "Code Composer Studio";
          genericName = "Code Composer Studio";
          categories = [ "Development" ];
        };

        buildInputs = [
            openssl
            zlib
            glib
            jdk
            unzip
            steam-run
            tree
       ];

        sourceRoot = ".";
        installPhase = ''
          runHook preInstall

          echo "Running main CCS installer in unattended mode"

          # TODO: Make this configurable
          # --enable-components takes the following options as a comma separated list:
          # PF_MSP430: MSP430 ultra-low power MCUs
          # PF_MSP432: SimpleLink MSP432 low power + performance MCUs
          # PF_MSPM0: MSPM0 32-bit Arm Cortex-M0+ General Purpose MCUs
          # PF_WCONN: Wireless connectivity
          # PF_C28: C2000 real-time MCUs
          # PF_TM4C: TM4C12x ARM Cortex-M4F core-based MCUs
          # PF_HERCULES: Hercules Safety MCUs
          # PF_SITARA: Sitara AM3x, AM4x, AM5x and AM6x MPUs
          # PF_SITARA_MCU: Sitara AM2x MCUs
          # PF_OMAPL: OMAP-L1x DSP + ARM9 Processor
          # PF_DAVINCI: DaVinci (DM) Video Processors
          # PF_OMAP: OMAP Processors
          # PF_TDA_DRA: TDAx Driver Assistance SoCs & Jacinto DRAx Infotainment SoCs
          # PF_C55: C55x ultra-low-power DSP
          # PF_C6000SC: C6000 Power-Optimized DSP
          # PF_C66AK_KEYSTONE: 66AK2x multicore DSP + ARM Processors & C66x KeyStone multicore DSP
          # PF_MMWAVE: mmWave Sensors
          # PF_C64MC: C64x multicore DSP
          # PF_DIGITAL_POWER: UCD Digital Power Controllers
          # PF_PGA: PGA Sensor Signal Conditioners

          steam-run ./CCS${version}.${build}_linux-x64/ccs_setup_${version}.${build}.run --mode unattended --prefix /build/ti/ \
            --enable-components PF_C28

          #echo "Building libraries"
          # compile the libraries for your target arch
          # PATH=/build/ti/ccs/tools/compiler/ti-cgt-arm_20.2.7.LTS/bin:$PATH steam-run /build/ti/ccs/tools/compiler/ti-cgt-arm_20.2.7.LTS/lib/mklib --pattern TI-RTOS.lib
          # PATH=/build/ti/ccs/tools/compiler/ti_cgt_armllvm_4.0.0.LTS/bin:$PATH steam-run /build/ti/ccs/tools/compiler/ti_cgt_armllvm_4.0.0.LTS/lib/mklib --pattern TI-RTOS.lib
          #PATH=/build/ti/ccs/tools/compiler/ti-cgt-msp430_21.6.1.LTS/bin:$PATH steam-run /build/ti/ccs/tools/compiler/ti-cgt-msp430_21.6.1.LTS/lib/mklib --pattern TI-RTOS.lib

          
          echo Copying installed files to $out
          mv /build/ti $out

          mkdir -p $out/share/icons
          ln -s $out/ccs/doc/ccs.ico $out/share/icons/ccs.ico

          mkdir -p $out/share/applications
          cp ''${desktopItem}/share/applications/* $out/share/applications

          mkdir -p $out/bin
          echo "#! /usr/bin/env bash" > $out/bin/ccs
          echo "${steam-run}/bin/steam-run $out/ccs/eclipse/ccstudio" >> $out/bin/ccs
          chmod oug+x $out/bin/ccs

          '';

        meta = with lib; {
          homepage = "https://ti.org";
          description = "CodeComposerStudio";
          platforms = platforms.linux;
        };
      };
      default = self.packages.x86_64-linux.CodeComposerStudio;
    };
  };
}