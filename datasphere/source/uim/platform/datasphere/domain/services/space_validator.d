/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.services.space_validator;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
struct SpaceValidator {
  static bool validateName(string name) {
    return name.length > 0 && name.length <= 256;
  }

  static bool validateId(string id) {
    return id.length > 0 && id.length <= 128;
  }

  static string validate(SpaceId id, string name) {
    if (!validateId(id.value))
      return "Space ID must be between 1 and 128 characters";
    if (!validateName(name))
      return "Space name must be between 1 and 256 characters";
    return "";
  }
}
