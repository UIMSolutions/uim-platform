/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.dtos.application;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

struct ApplicationSpec {
  string name;
  string description;
  AppRegistrationType registrationType = AppRegistrationType.apiAndEvents;
  AppApiEntry[] apis;
  AppEventEntry[] events;
  KeyValue[] labels;
}

alias RegisterApplicationRequest = CreateRequest!(KymaEnvironmentId, ApplicationSpec);
alias UpdateApplicationRequest = UpdateRequest!(ApplicationId, ApplicationSpec);
