{ ... }:

{
  # Wi-Fi config so the Pi joins the network automatically on boot --
  # no need to run raspi-config or nmcli after each SD card flash.
  #
  # Fill in pskRaw yourself (don't put the plaintext password here):
  #   wpa_passphrase "YOUR_SSID" "your password" | grep -oP '(?<=\spsk=)[0-9a-f]{64}'
  # That prints a 64-character hex string -- paste it below as pskRaw,
  # then delete this comment block.
  networking.wireless = {
    enable = true;
    networks = {
      "AquaponicsIOT" = {
        pskRaw = "47370642c6a9f219d2988df358fc8400634b0d0ed9b3c8cb48abbeaf1265fad8";
      };
    };
  };
}
