/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.services.instance_validator;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
struct InstanceValidator {
  static bool validateName(string name) {
    return name.length > 0 && name.length <= 256;
  }

  static bool validateId(string id) {
    return id.length > 0 && id.length <= 128;
  }

  static string validate(string id, string name) {
    if (!validateId(id))
      return "Instance ID must be between 1 and 128 characters";
    if (!validateName(name))
      return "Instance name must be between 1 and 256 characters";
    return "";
  }
}
