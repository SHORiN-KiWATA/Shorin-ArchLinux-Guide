{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS 官方软件源，这里使用 nixos-25.11 分支
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, noctalia, ... }@inputs: {
    # TODO 请将下面的 my-nixos 替换成你的 hostname
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
	specialArgs = { inherit inputs; };
      modules = [
        # 这里导入之前我们使用的 configuration.nix，
        # 这样旧的配置文件仍然能生效
        ./configuration.nix
	./noctalia.nix
      ];
    };
  };
}
