/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.entities.address_record;

// import uim.platform.data.quality.domain.types;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
/// An address record for cleansing and geocoding.
struct AddressRecord {
  mixin TenantEntity!(AddressId);

  RecordId sourceRecordId; // link to originating record

  // Input fields
  string inputLine1;
  string inputLine2;
  string inputCity;
  string inputRegion;
  string inputPostalCode;
  string inputCountry;

  // Cleansed output
  string line1;
  string line2;
  string city;
  string region;
  string postalCode;
  string country;
  string countryIso2;

  AddressType addressType = AddressType.unknown;
  AddressQuality quality = AddressQuality.unverifiable;

  // Geocoding
  double latitude = 0.0;
  double longitude = 0.0;
  GeocodePrecision geocodePrecision = GeocodePrecision.none;

  // Metadata
  CleansingAction[] appliedActions;
  string[] changeLog; // human-readable changes
  long cleansedAt;
  long geocodedAt;

  Json toJson() const {
    return entityToJson
      .set("sourceRecordId", sourceRecordId)
      .set("inputLine1", inputLine1)
      .set("inputLine2", inputLine2)
      .set("inputCity", inputCity)
      .set("inputRegion", inputRegion)
      .set("inputPostalCode", inputPostalCode)
      .set("inputCountry", inputCountry)
      .set("line1", line1)
      .set("line2", line2)
      .set("city", city)
      .set("region", region)
      .set("postalCode", postalCode)
      .set("country", country)
      .set("countryIso2", countryIso2)
      .set("addressType", addressType.to!string)
      .set("quality", quality.to!string)
      .set("latitude", latitude)
      .set("longitude", longitude)
      .set("geocodePrecision", geocodePrecision.to!string)
      .set("appliedActions", appliedActions)
      .set("changeLog", changeLog)
      .set("cleansedAt", cleansedAt)
      .set("geocodedAt", geocodedAt);
  }
}
