/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.dtos.api_rule;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

struct ApiRuleSpec {
  string name;
  string description;
  string serviceName;
  int servicePort = 80;
  string gateway = "kyma-system/kyma-gateway";
  /// "" = <name>.<cluster domain>
  string host;
  ApiRuleEntry[] rules;
  bool corsEnabled;
  string[] corsAllowOrigins;
  string[] corsAllowMethods;
  string[] corsAllowHeaders;
  KeyValue[] labels;
}

alias CreateApiRuleRequest = CreateRequest!(NamespaceId, ApiRuleSpec);
alias UpdateApiRuleRequest = UpdateRequest!(ApiRuleId, ApiRuleSpec);
