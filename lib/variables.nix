# ============================================================
# Identity
# ============================================================
#
# Single source of truth. This file existed but nothing imported
# it, so the values had drifted out of sync with the real config:
# username was "subha279" (the account is `subha`) and hostname
# was "Subha" (the host is `subha`).
#
# Consumed by:
#   hosts/laptop/default.nix    hostname
#   modules/core/default.nix    timezone, locale
#   modules/users/default.nix   username
#   home/git/default.nix        fullName, email
#
# ============================================================

{
  # Linux account name.
  username = "subha";

  # networking.hostName
  hostname = "subha";

  # Git identity. Deliberately different from `username`: this is the
  # forge account, not the local account.
  gitUser = "subha279";

  fullName = "Subha";

  email = "111702137+subha279@users.noreply.github.com";

  timezone = "Asia/Kolkata";

  locale = "en_US.UTF-8";
}
