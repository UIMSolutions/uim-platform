/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.domain.enumerations;

import uim.platform.hana_spatial;

// mixin(ShowModule!());

@safe:

// Geocoding result quality/confidence level
enum GeocodingMatchLevel {
  exact,
  street,
  district,
  city,
  postalCode,
  state,
  country,
  unknown,
}

// Type of geocoding operation
enum GeocodingType {
  forward_,   // address -> coordinates
  reverse_,   // coordinates -> address
  batch_,     // multiple addresses
}

// Route travel mode
enum TravelMode {
  car,
  truck,
  pedestrian,
  bicycle,
  publicTransport,
}

// Route optimization strategy
enum RouteOptimization {
  fastest,
  shortest,
  scenic,
  efficient,
}

// Route/calculation status
enum SpatialJobStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

// POI category
enum PoiCategory {
  accommodation,
  atm,
  bank,
  business,
  education,
  entertainment,
  food,
  government,
  health,
  leisure,
  natural,
  parking,
  petrolStation,
  religious,
  shopping,
  sport,
  tourism,
  transport,
  other,
}

// Isoline calculation mode
enum IsolineMode {
  time,       // reachable within N seconds
  distance,   // reachable within N meters
}

// Spatial feature geometry type (GeoJSON compatible)
enum GeometryType {
  point,
  multiPoint,
  lineString,
  multiLineString,
  polygon,
  multiPolygon,
  geometryCollection,
}

// Spatial layer type
enum SpatialLayerType {
  point,
  line,
  polygon,
  mixed,
}

// Provider status
enum ProviderStatus {
  active,
  inactive,
  maintenance,
  deprecated_,
}

// Provider type
enum ProviderType {
  here,
  mapbox,
  openStreetMap,
  googleMaps,
  esri,
  custom,
}

// Geofence zone shape
enum GeofenceShapeType {
  circle,
  polygon,
  boundingBox,
}

// Geofence violation event type
enum GeofenceEventType {
  entry,
  exit,
  inside,
  outside,
}
