{
  lib,
  themeData,
  themeNames,
  base16,
}:

let
  kvconfigTemplate = ../templates/kvconfig.mustache;
  kvantumSvgTemplate = ../templates/kvantum.svg.mustache;

  toKvantumConfig = themeId: base16.renderTemplate kvconfigTemplate (base16.toBase16 themeId);

  toKvantumSvg = themeId: base16.renderTemplate kvantumSvgTemplate (base16.toBase16 themeId);

  kvantumConfigFiles = lib.genAttrs themeNames (themeId: {
    text = toKvantumConfig themeId;
  });

  kvantumSvgFiles = lib.genAttrs themeNames (themeId: {
    text = toKvantumSvg themeId;
  });

in
{
  inherit
    toKvantumConfig
    toKvantumSvg
    kvantumConfigFiles
    kvantumSvgFiles
    ;

  generatedKvantumConfigFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "sunflower/themes/${themeId}/kvantum/Base16Kvantum.kvconfig" file
  ) kvantumConfigFiles;

  generatedKvantumSvgFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "sunflower/themes/${themeId}/kvantum/Base16Kvantum.svg" file
  ) kvantumSvgFiles;
}
