return {
  cmd = { "qmlls" },
  filetypes = {
    "qml",
    "qmljs",
  },
  root_markers = {
    ".qmlls.ini",
    "CMakeLists.txt",
    "qmldir",
    ".git",
  },
  -- Let qmlls work for standalone QML files as well as full projects.
  workspace_required = false,
}
