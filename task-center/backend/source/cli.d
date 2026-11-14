/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line entry point. Uses the same container and storage as the server.
///
///   dub run --config=cli -- help
///   ./build/uim-task-center-cli seed --data-file=data/task-center.json
///   ./build/uim-task-center-cli inbox --user=anna
///   ./build/uim-task-center-cli approve po-4711 --user=anna --comment="Terms checked"
///   ./build/uim-task-center-cli list Tasks --filter="priority eq 'veryHigh'" --orderby="dueDate asc"
module cli;

import uim.platform.task_center;

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
    TaskCenterContainer container;
    try
      container = new TaskCenterContainer(loadTaskCenterConfig(cliOverrides(pre), pre.opt("config-dir", "config")), null, null,
        new NullTaskEventPublisher);
    catch (Exception e) {
      stderr.writeln("error: ", e.msg);
      return 1;
    }
    return buildTaskCenterCli(container).run(argv[1 .. $]);
  }
}
