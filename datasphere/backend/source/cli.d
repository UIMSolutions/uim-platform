/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-datasphere-cli seed --data-file=data/datasphere.json
///   ./build/uim-datasphere-cli run nightly
///   ./build/uim-datasphere-cli runs SALES --status=failed
///   ./build/uim-datasphere-cli list Views --filter="deploymentStatus eq 'changesToDeploy'"
module cli;

import uim.platform.datasphere;

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
    DspContainer container;
    try {
      Json[string] o = cliOverrides(pre);
      container = new DspContainer(loadDspConfig(o, pre.opt("config-dir", "config")));
      container.audit.log = false;
    } catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildDspCli(container).run(argv[1 .. $]);
  }
}
