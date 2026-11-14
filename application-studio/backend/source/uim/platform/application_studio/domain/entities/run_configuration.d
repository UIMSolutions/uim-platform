/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.entities.run_configuration;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// How a project is launched (run, debug, test, preview) inside its dev space.
struct RunConfiguration {
  mixin TenantEntity!RunConfigurationId;

  ProjectId projectId;
  string projectName;
  DevSpaceId devSpaceId;
  string name; /// unique per project
  string description;
  RunMode mode = RunMode.run;
  RunStatus status = RunStatus.idle;
  string statusMessage;

  string entryPoint; /// script / main class, e.g. "npm start"
  string[] arguments;
  KeyValue[] environment; /// environment variables
  int port = 4004;
  int debugPort; /// required in debug mode
  string[] serviceBindings; /// binding names of the same dev space
  string url; /// preview URL while running
  long lastRunAt;
  int runCount;
}
