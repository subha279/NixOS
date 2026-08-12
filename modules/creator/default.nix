{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    davinci-resolve
  ];
}
