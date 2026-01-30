{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "pomodoro-tui";
  version = "0.1.0";

  # Ensure you move your 'bin' folder to this directory!
  src = ./bin;

  # Fixes "Interpreter not found" for pre-compiled binaries
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  # Runtime Libraries (ALSA support)
  buildInputs = [
    pkgs.alsa-lib
    pkgs.stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    install -m755 -D pomodoro-tui $out/bin/pomodoro-tui
    runHook postInstall
  '';
}
