/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.types;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:

// --- Domain ID types ---

struct GeocodingResultId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct RouteId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct PointOfInterestId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct IsolineId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct GeofenceZoneId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct SpatialLayerId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct SpatialFeatureId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct ProviderId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct GeocodingJobId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

// --- Value types ---

struct GeoCoordinate {
  double latitude;
  double longitude;

  Json toJson() const {
    return Json.emptyObject()
      .set("latitude", latitude)
      .set("longitude", longitude);
  }
}

struct BoundingBox {
  double north;
  double south;
  double east;
  double west;

  Json toJson() const {
    return Json.emptyObject()
      .set("north", north)
      .set("south", south)
      .set("east", east)
      .set("west", west);
  }
}

struct Address {
  string street;
  string houseNumber;
  string city;
  string postalCode;
  string country;
  string countryCode;
  string state;
  string district;

  Json toJson() const {
    return Json.emptyObject()
      .set("street", street)
      .set("houseNumber", houseNumber)
      .set("city", city)
      .set("postalCode", postalCode)
      .set("country", country)
      .set("countryCode", countryCode)
      .set("state", state)
      .set("district", district);
  }
}
