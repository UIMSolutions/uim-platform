/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.entities.route;

import uim.platform.hana_spatial;
mixin(ShowModule!());

@safe:

struct RouteLeg {
  GeoCoordinate origin;
  GeoCoordinate destination;
  double distanceMeters;
  long durationSeconds;
  string summary;

  Json toJson() const {
    return Json.emptyObject()
      .set("origin", origin.toJson())
      .set("destination", destination.toJson())
      .set("distanceMeters", distanceMeters)
      .set("durationSeconds", durationSeconds)
      .set("summary", summary);
  }
}

struct Route {
  mixin TenantEntity!(RouteId);

  GeoCoordinate origin;
  GeoCoordinate destination;
  string originLabel;
  string destinationLabel;

  TravelMode travelMode;
  RouteOptimization optimization;

  double totalDistanceMeters;
  long totalDurationSeconds;

  RouteLeg[] legs;

  // GeoJSON LineString polyline as JSON string
  string polyline;

  string providerId;
  string language;

  Json toJson() const {
    auto legsArr = Json.emptyArray;
    foreach (leg; legs) legsArr ~= leg.toJson();

    return entityToJson()
      .set("origin", origin.toJson())
      .set("destination", destination.toJson())
      .set("originLabel", originLabel)
      .set("destinationLabel", destinationLabel)
      .set("travelMode", travelMode.to!string)
      .set("optimization", optimization.to!string)
      .set("totalDistanceMeters", totalDistanceMeters)
      .set("totalDurationSeconds", totalDurationSeconds)
      .set("legs", legsArr)
      .set("polyline", polyline)
      .set("providerId", providerId)
      .set("language", language);
  }
}
