/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-oauth-cli seed --data-file=data/oauth.json
///   ./build/uim-oauth-cli list OAuthClients --filter="status eq 'active'"
///   ./build/uim-oauth-cli token sb-billing-service --secret=... --scope="orders.read"
module cli;

import uim.platform.oauth;

version (unittest) {
} else {
  int main(string[] argv) {
    import std.stdio : stderr;

    CliArgs pre;
    try
      pre = CliArgs.parse(argv[1 .. $]);
    catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 2;
    }
    OAuthContainer container;
    try
      container = new OAuthContainer(loadOAuthConfig(cliOverrides(pre), pre.opt("config-dir", "config")));
    catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildOAuthCli(container).run(argv[1 .. $]);
  }
}
