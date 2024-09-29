{ stdenv, fetchFromGitHub }:
{
  aerial-sddm-theme = stdenv.mkDerivation rec {
    pname = "aerial-sddm-theme";
    version = "92b85ec";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/sddm-theme-dialog
    '';
    src = fetchFromGitHub {
      owner = "3ximus";
      repo = "aerial-sddm-theme";
      rev = "92b85ec7d177683f39a2beae40cde3ce9c2b74b0";
      sha256 = "0MdjhuftOrIDnqMvADPU9/55s/Upua9YpfIz0wpGg4E=";
    };
  };
}
