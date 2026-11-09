/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.domain.enumerations.config_status;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Audit log configuration status.
enum ConfigStatus {
  enabled,
  disabled,
}

ConfigStatus toConfigStatus(string value) {
  mixin(EnumSwitch("ConfigStatus", "enabled"));
}

ConfigStatus[] toConfigStatus(string[] values) {
  return values.map!toConfigStatus.array;
}

string toString(ConfigStatus s) {
  return s.to!string;
}

string[] toString(ConfigStatus[] statuses) {
  return statuses.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("ConfigStatus"));

  assert("enabled".toConfigStatus == ConfigStatus.enabled);
  assert("disabled".toConfigStatus == ConfigStatus.disabled);

  assert(ConfigStatus.enabled.toString == "enabled");
  assert(ConfigStatus.disabled.toString == "disabled");

  assert(["enabled", "disabled"].toConfigStatus == [ConfigStatus.enabled, ConfigStatus.disabled
    ]);
  assert([ConfigStatus.enabled, ConfigStatus.disabled].toString == ["enabled", "disabled"
    ]);
}
