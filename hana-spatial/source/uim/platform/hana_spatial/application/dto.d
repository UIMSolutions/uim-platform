/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.application.dto;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:

// --- Geocoding ---

struct GeocodeAddressRequest {
  TenantId tenantId;
  string id;
  string address;
  string language;
  string countryCode;
  string providerId;
}

struct ReverseGeocodeRequest {
  TenantId tenantId;
  string id;
  double latitude;
  double longitude;
  string language;
  string providerId;
}

// --- Routing ---

struct CalculateRouteRequest {
  TenantId tenantId;
  string id;
  double originLat;
  double originLon;
  double destinationLat;
  double destinationLon;
  string originLabel;
  string destinationLabel;
  string travelMode;
  string optimization;
  string language;
  string providerId;
}

// --- Points of Interest ---

struct CreatePoiRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string category;
  double latitude;
  double longitude;
  string street;
  string houseNumber;
  string city;
  string postalCode;
  string country;
  string countryCode;
  string phoneNumber;
  string website;
  string openingHours;
  string providerId;
  string externalId;
  string[][] attributes;
}

struct UpdatePoiRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string category;
  double latitude;
  double longitude;
  string phoneNumber;
  string website;
  string openingHours;
}

// --- Isoline ---

struct CalculateIsolineRequest {
  TenantId tenantId;
  string id;
  double centerLat;
  double centerLon;
  string mode;          // "time" or "distance"
  double rangeValue;
  string travelMode;
  string providerId;
}

// --- Geofence Zone ---

struct CreateGeofenceZoneRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string shapeType;
  double centerLat;
  double centerLon;
  double radiusMeters;
  string polygon;       // GeoJSON polygon string
  bool active;
  string[][] metadata;
}

struct UpdateGeofenceZoneRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  double radiusMeters;
  string polygon;
  bool active;
}

struct GeofenceCheckRequest {
  TenantId tenantId;
  string zoneId;
  double latitude;
  double longitude;
}

struct GeofenceCheckResult {
  bool inside;
  string zoneId;
  string zoneName;
}

// --- Spatial Layer ---

struct CreateSpatialLayerRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string type;
  string coordinateSystem;
  bool isPublic;
  string[][] metadata;
}

struct UpdateSpatialLayerRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  bool isPublic;
}

// --- Spatial Feature ---

struct CreateSpatialFeatureRequest {
  TenantId tenantId;
  string id;
  string layerId;
  string name;
  string geometryType;
  string geometry;      // GeoJSON geometry string
  string properties;    // GeoJSON properties string
  string[][] tags;
}

struct UpdateSpatialFeatureRequest {
  TenantId tenantId;
  string id;
  string name;
  string geometry;
  string properties;
  string[][] tags;
}

// --- Provider ---

struct CreateProviderRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string type;
  string apiKey;
  string baseUrl;
  bool supportsGeocoding;
  bool supportsRouting;
  bool supportsMapping;
  bool supportsIsoline;
  bool supportsPoi;
  string[] supportedRegions;
  string[][] config;
}

struct UpdateProviderRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string status;
  string apiKey;
  string baseUrl;
  bool supportsGeocoding;
  bool supportsRouting;
  bool supportsMapping;
  bool supportsIsoline;
  bool supportsPoi;
}

// --- Geocoding Job ---

struct CreateGeocodingJobRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string providerId;
  string language;
  string countryCode;
  string[] addresses;
  string[] externalRefs;
}

struct GeocodingJobActionRequest {
  TenantId tenantId;
  string id;
  string action;    // "start", "cancel"
}
