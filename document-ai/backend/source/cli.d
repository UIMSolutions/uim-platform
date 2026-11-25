/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-document-ai-cli seed --data-file=data/document-ai.json
///   ./build/uim-document-ai-cli upload invoice-42.pdf --type=supplier-invoice --extract
///   ./build/uim-document-ai-cli list Documents --filter="needsReview eq true"
module cli;

import uim.platform.document_ai;

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
    DaiContainer container;
    try {
      Json[string] o = cliOverrides(pre);
      o["workerIntervalSeconds"] = 0; // the CLI extracts inline
      container = new DaiContainer(loadDaiConfig(o, pre.opt("config-dir", "config")));
      container.events.log = false;
    } catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildDaiCli(container).run(argv[1 .. $]);
  }
}
