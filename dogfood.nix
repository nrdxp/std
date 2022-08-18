{
  growOn,
  inputs,
  clades,
  harvest,
}:
growOn {
  inherit inputs;
  cellsFrom = ./cells;
  organelles = [
    (clades.runnables "cli")
    (clades.functions "lib")
    (clades.functions "devshellProfiles")
    (clades.devshells "devshells")
    (clades.installables "packages")
    (clades.nixago "nixago")
    (clades.data "data")
    (clades.files "files")
  ];
} {
  devShells = harvest inputs.self ["automation" "devshells"];
  packages = harvest inputs.self [["std" "cli"] ["std" "packages"]];
  lib = (harvest inputs.self ["automation" "lib"]).x86_64-linux;
}
