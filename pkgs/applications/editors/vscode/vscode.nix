{ stdenv, lib, callPackage, fetchurl, fetchzip, isInsiders ? false }:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  plat = {
    x86_64-linux = "linux-x64";
    x86_64-darwin = "darwin";
    aarch64-linux = "linux-arm64";
    aarch64-darwin = "darwin-arm64";
    armv7l-linux = "linux-armhf";
  }.${system} or throwSystem;

  archive_fmt = if stdenv.isDarwin then "zip" else "tar.gz";

  sha256 = {
    x86_64-linux = "1ldn2m7mi3sfkcv417a2ci68p8r178kfr9bf1wx6j0r09sn5r4i0";
    x86_64-darwin = "1pkxcj6dz5lcvf0ivzafvwvcyw2098ylxrqqzj9dfgfad29kyszd";
    aarch64-linux = "1q1l7vrf4ifv6y46b4zz9km83wrsq80wx6rb4rnqkgijpbx02f7z";
    aarch64-darwin = "1zhvbn6kmp99a5p0299256fm08y67rfzz03zygif7y20zrmr27ka";
    armv7l-linux = "0jn2li0j1cmk5m61ha6m4lskc80q1j7mfmgidc3x9x9yiv6yacr7";
  }.${system} or throwSystem;

  icons = if stdenv.isDarwin || isInsiders then "" else fetchzip {
    url = "https://vscodeassets.azureedge.net/public/visual-studio-code-icons.zip";
    sha256 = "sha256-ePUcc/ePGJeMw1U3LVuPDx0XDgb4PIkfCJM3zSO9gsk=";
  };
in
  callPackage ./generic.nix rec {
    # Please backport all compatible updates to the stable release.
    # This is important for the extension ecosystem.
    version = "1.70.0";
    pname = "vscode";

    executableName = "code" + lib.optionalString isInsiders "-insiders";
    longName = "Visual Studio Code" + lib.optionalString isInsiders " - Insiders";
    shortName = "Code" + lib.optionalString isInsiders " - Insiders";

    src = fetchurl {
      name = "VSCode_${version}_${plat}.${archive_fmt}";
      url = "https://update.code.visualstudio.com/${version}/${plat}/stable";
      inherit sha256;
    };

    sourceRoot = "";

    updateScript = ./update-vscode.sh;

    postInstall = if stdenv.isDarwin || isInsiders then "" else ''
      install -Dm644 ${icons}/vscode.svg $out/share/icons/hicolor/scalable/apps/code.svg
    '';

    meta = with lib; {
      description = ''
        Open source source code editor developed by Microsoft for Windows,
        Linux and macOS
      '';
      mainProgram = "code";
      longDescription = ''
        Open source source code editor developed by Microsoft for Windows,
        Linux and macOS. It includes support for debugging, embedded Git
        control, syntax highlighting, intelligent code completion, snippets,
        and code refactoring. It is also customizable, so users can change the
        editor's theme, keyboard shortcuts, and preferences
      '';
      homepage = "https://code.visualstudio.com/";
      downloadPage = "https://code.visualstudio.com/Updates";
      license = licenses.unfree;
      maintainers = with maintainers; [ eadwu synthetica maxeaubrey bobby285271 ];
      platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" "armv7l-linux" ];
    };
  }
