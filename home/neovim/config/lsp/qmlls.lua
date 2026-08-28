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
  workspace_required = false,
}
