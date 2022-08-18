{
  inputs,
  cell,
}: {
  envrc = default:
    inputs.nixpkgs.writeShellApplication {
      name = "envrc";

      text = ''
        [[ -f .envrc.local ]] && source_env_if_exists .envrc.local
        DEVSHELL_TARGET="''${DEVSHELL_TARGET:-${default}}"

        source_env "${./direnv_lib.sh}"
        use std cells //automation/devshells:"''${DEVSHELL_TARGET}"
      '';
    };
}
