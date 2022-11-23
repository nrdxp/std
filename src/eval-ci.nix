self: let
  inherit (self.inputs.std.inputs) nixpkgs dmerge;
  inherit (nixpkgs) lib;

  mergeAll = builtins.foldl' dmerge.merge {};

  split = fragment:
    lib.attrByPath
    (lib.splitString ''"."''
      (lib.removeSuffix "\"" (lib.removePrefix "\"" fragment)));
in
  builtins.mapAttrs (system: set:
    mergeAll (map (
        target: {
          ${target.action}."${"//${target.cell}/${target.block}/${target.name}:${target.action}"}" = let
            fromSelf = fragment:
              (split fragment)
              null
              self;

            fragments = lib.filterAttrs (n: _: lib.hasSuffix "Fragment" n) target;

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
            lib.mapAttrs' (name: fragment: {
              name = lib.removeSuffix "Fragment" name + "Drv";
              value = f (fromSelf fragment);
            })
            fragments;
        }
      )
      set))
