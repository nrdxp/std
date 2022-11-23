self: let
  inherit (self.inputs.std.inputs) nixpkgs dmerge;
  inherit (nixpkgs) lib;

  mergeAll = builtins.foldl' dmerge.merge {targets = [];};

  split = fragment:
    lib.attrByPath
    (lib.splitString ''"."''
      (lib.removeSuffix "\"" (lib.removePrefix "\"" fragment)));

  fromSelf = fragment:
    (split fragment)
    null
    self;

  f = drv:
    lib.optionalAttrs (drv ? drvPath)
    (builtins.foldl'
      (acc: output:
        dmerge.merge acc
        {
          path = drv.drvPath;
          outputs = {
            ${output} = {path = toString drv.${output};};
          };
        })
      {}
      drv.outputs);
in
  builtins.mapAttrs (system: set:
    mergeAll (map (
        target: {
          ${target.action}."${"//${target.cell}/${target.block}/${target.name}"}" =
            f (fromSelf target.actionFragment);

          targets = let
            targetDrv = f (fromSelf target.targetFragment);
          in
            dmerge.append (
              if targetDrv != {}
              then [
                (builtins.mapAttrs (n: v:
                  if n == "outputs"
                  then builtins.mapAttrs (_: v': v' // {cached = false;}) v
                  else v)
                targetDrv)
              ]
              else []
            );
        }
      )
      set))
