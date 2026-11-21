/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-ai-core-cli seed --data-file=data/ai-core.json
///   ./build/uim-ai-core-cli list Executions --filter="status eq 'RUNNING'"
///   ./build/uim-ai-core-cli run default train-default
module cli;

import uim.platform.ai_core;

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
    AiCoreContainer container;
    try {
      container = new AiCoreContainer(loadAiCoreConfig(cliOverrides(pre), pre.opt("config-dir", "config")));
      container.events.log = false;
    } catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildAiCoreCli(container).run(argv[1 .. $]);
  }
}
