{
  lib,
  themeData,
  themeNames,
}:

let
  themeToLua =
    themeId:
    let
      theme = themeData.themes.${themeId};
      colors = theme.colors;
      fonts = themeData.global.fonts;
      ui = themeData.global.ui;
    in
    ''
      return {
        id = "${themeId}",
        name = "${theme.name}",
        description = "${theme.description}",

        fonts = {
          interface = "${fonts.interface.name}",
          terminal = "${fonts.terminal.name}",
          emoji = "${fonts.emoji.name}",
        },

        colors = {
          background = "${colors.background}",
          backgroundDark = "${colors.backgroundDark}",

          surface = "${colors.surface}",
          surfaceHover = "${colors.surfaceHover}",
          surfaceActive = "${colors.surfaceActive}",

          border = "${colors.border}",
          borderFocus = "${colors.borderFocus}",
          separator = "${colors.separator}",

          text = "${colors.text}",
          textSecondary = "${colors.textSecondary}",
          textMuted = "${colors.textMuted}",

          accent = "${colors.accent}",
          accentHover = "${colors.accentHover}",
          accentActive = "${colors.accentActive}",
          accentMuted = "${colors.accentMuted}",
          accentForeground = "${colors.accentForeground}",

          success = "${colors.success}",
          warning = "${colors.warning}",
          error = "${colors.error}",
          info = "${colors.info}",

          terminalBlack = "${colors.terminalBlack}",
          terminalRed = "${colors.terminalRed}",
          terminalGreen = "${colors.terminalGreen}",
          terminalYellow = "${colors.terminalYellow}",
          terminalBlue = "${colors.terminalBlue}",
          terminalMagenta = "${colors.terminalMagenta}",
          terminalCyan = "${colors.terminalCyan}",
          terminalWhite = "${colors.terminalWhite}",

          syntax = {
            comment = "${colors.syntax.comment}";
            variable = "${colors.syntax.variable}";
            parameter = "${colors.syntax.parameter}";
            property = "${colors.syntax.property}";
            func = "${colors.syntax.func}";
            method = "${colors.syntax.method}";
            keyword = "${colors.syntax.keyword}";
            keywordControl = "${colors.syntax.keywordControl}";
            type = "${colors.syntax.type}";
            constant = "${colors.syntax.constant}";
            string = "${colors.syntax.string}";
            number = "${colors.syntax.number}";
            boolean = "${colors.syntax.boolean}";
            operator = "${colors.syntax.operator}";
            punctuation = "${colors.syntax.punctuation}";
            tag = "${colors.syntax.tag}";
            attribute = "${colors.syntax.attribute}";
            namespace = "${colors.syntax.namespace}";
            builtin = "${colors.syntax.builtin}";
            regex = "${colors.syntax.regex}";
            special = "${colors.syntax.special}";
            macro = "${colors.syntax.macro}";
          },

          terminalBrightBlack = "${colors.terminalBrightBlack}",
          terminalBrightRed = "${colors.terminalBrightRed}",
          terminalBrightGreen = "${colors.terminalBrightGreen}",
          terminalBrightYellow = "${colors.terminalBrightYellow}",
          terminalBrightBlue = "${colors.terminalBrightBlue}",
          terminalBrightMagenta = "${colors.terminalBrightMagenta}",
          terminalBrightCyan = "${colors.terminalBrightCyan}",
          terminalBrightWhite = "${colors.terminalBrightWhite}",
        },

        ui = {
          borderWidth = ${toString ui.borderWidth},

          radius = ${toString ui.radius},
          radiusSmall = ${toString ui.radiusSmall},
          radiusLarge = ${toString ui.radiusLarge},

          iconSize = ${toString ui.iconSize},

          fontSize = ${toString ui.fontSize},
          fontSizeSmall = ${toString ui.fontSizeSmall},
          fontSizeLarge = ${toString ui.fontSizeLarge},

          shadowOpacity = ${toString ui.shadowOpacity},
          surfaceOpacity = ${toString ui.surfaceOpacity},
          windowOpacity = ${toString ui.windowOpacity},

          glassOpacity = ${toString ui.glassOpacity},
          glassLuminosity = ${toString ui.glassLuminosity},
          glassGradientOpacity = ${toString ui.glassGradientOpacity},
          glassGrainOpacity = ${toString ui.glassGrainOpacity},
          glassRimOpacity = ${toString ui.glassRimOpacity},

          glassSpecularOpacity = ${toString ui.glassSpecularOpacity},
          glassLensOpacity = ${toString ui.glassLensOpacity},
          glassDepthOpacity = ${toString ui.glassDepthOpacity},
          glassClarity = ${toString ui.glassClarity},

          terminalOpacity = ${toString ui.terminalOpacity},
          editorFloatBlend = ${toString ui.editorFloatBlend},

          clock = {
            hour = "${ui.clock.hour}",
            separator = "${ui.clock.separator}",
            minute = "${ui.clock.minute}",
            second = "${ui.clock.second}",
          },
        },
      }
    '';

  themeToJson =
    themeId:
    builtins.toJSON {
      id = themeId;
      name = themeData.themes.${themeId}.name;
      description = themeData.themes.${themeId}.description;

      fonts = {
        interface = themeData.global.fonts.interface.name;
        terminal = themeData.global.fonts.terminal.name;
        emoji = themeData.global.fonts.emoji.name;
      };

      colors = themeData.themes.${themeId}.colors;
      ui = themeData.global.ui;
    };

  luaThemeFiles = lib.genAttrs themeNames (themeId: {
    text = themeToLua themeId;
  });

  jsonThemeFiles = lib.genAttrs themeNames (themeId: {
    text = themeToJson themeId;
  });

in
{
  inherit
    themeToLua
    themeToJson
    luaThemeFiles
    jsonThemeFiles
    ;

  generatedLuaFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "sunflower/themes/${themeId}.lua" file
  ) luaThemeFiles;

  generatedJsonFiles = lib.mapAttrs' (
    themeId: file: lib.nameValuePair "sunflower/themes/${themeId}.json" file
  ) jsonThemeFiles;
}
