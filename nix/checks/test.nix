(import ./lib.nix) {
  name = "nixpkgs-merger-bot";
  nodes = {
    # `self` here is set by using specialArgs in `lib.nix`
    node1 = { self, pkgs, ... }: {
      imports = [
        self.nixosModules.nixpkgs-merge-bot
      ];
      services.nixpkgs-merge-bot = {
        enable = true;
        hostname = "example.com";
        webhook-secret-file = pkgs.writeText "dummy.secret" "secret";
        github-app-login = "nixpkgs-merge-bot";
        github-app-id = 1234;
        github-app-private-key-file = pkgs.writeText "dummy.key" "key";
      };

    };
  };
  # This is the test code that will check if our service is running correctly:
  testScript = ''
    start_all()
    node1.succeed("curl --unix-socket /run/nixpkgs-merge-bot.sock http://x/")
    # wait for our service to start
    node1.wait_for_unit("nixpkgs-merge-bot.service")
  '';
}
