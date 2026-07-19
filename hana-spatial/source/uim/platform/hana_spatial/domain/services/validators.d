/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.services.validators;

import uim.platform.hana_spatial;
mixin(ShowModule!());

@safe:

struct SpatialValidator {
  static string validateCoordinate(double lat, double lon) {
    if (lat < -90.0 || lat > 90.0)
      return "Latitude must be between -90 and 90";
    if (lon < -180.0 || lon > 180.0)
      return "Longitude must be between -180 and 180";
    return "";
  }

  static string validateId(string id) {
    if (id.length == 0)
      return "ID must not be empty";
    return "";
  }

  static string validateName(string name) {
    if (name.isEmpty)
      return "Name must not be empty";
    if (name.length > 255)
      return "Name must not exceed 255 characters";
    return "";
  }

  static string validateAddress(string address) {
    if (address.length == 0)
      return "Address must not be empty";
    return "";
  }

  static string validateProvider(string providerId) {
    if (providerId.length == 0)
      return "Provider ID must not be empty";
    return "";
  }

  static string validateRangeValue(double value) {
    if (value <= 0)
      return "Range value must be positive";
    return "";
  }

  static string validateLayer(string layerId) {
    if (layerId.length == 0)
      return "Layer ID must not be empty";
    return "";
  }
}
