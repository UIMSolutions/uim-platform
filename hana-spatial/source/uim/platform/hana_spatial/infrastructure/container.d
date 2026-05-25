/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.infrastructure.container;

import uim.platform.hana_spatial;

mixin(ShowModule!());

@safe:
struct Container {
  // Repositories (driven adapters)
  MemoryGeocodingResultRepository geocodingResultRepo;
  MemoryRouteRepository routeRepo;
  MemoryPointOfInterestRepository poiRepo;
  MemoryIsolineRepository isolineRepo;
  MemoryGeofenceZoneRepository geofenceZoneRepo;
  MemorySpatialLayerRepository spatialLayerRepo;
  MemorySpatialFeatureRepository spatialFeatureRepo;
  MemoryProviderRepository providerRepo;
  MemoryGeocodingJobRepository geocodingJobRepo;

  // Use cases (application layer)
  ManageGeocodingResultsUseCase manageGeocodingResults;
  ManageRoutesUseCase manageRoutes;
  ManagePointsOfInterestUseCase managePoi;
  ManageIsolinesUseCase manageIsolines;
  ManageGeofenceZonesUseCase manageGeofenceZones;
  ManageSpatialLayersUseCase manageSpatialLayers;
  ManageSpatialFeaturesUseCase manageSpatialFeatures;
  ManageProvidersUseCase manageProviders;
  ManageGeocodingJobsUseCase manageGeocodingJobs;

  // Controllers (driving adapters)
  GeocodingController geocodingController;
  RoutingController routingController;
  PoiController poiController;
  IsolineController isolineController;
  GeofenceController geofenceController;
  SpatialLayerController spatialLayerController;
  SpatialFeatureController spatialFeatureController;
  ProviderController providerController;
  GeocodingJobController geocodingJobController;
  HealthController healthController;
}

Container buildContainer(SrvConfig config) {
  Container c;

  // Infrastructure adapters
  c.geocodingResultRepo = new MemoryGeocodingResultRepository();
  c.routeRepo = new MemoryRouteRepository();
  c.poiRepo = new MemoryPointOfInterestRepository();
  c.isolineRepo = new MemoryIsolineRepository();
  c.geofenceZoneRepo = new MemoryGeofenceZoneRepository();
  c.spatialLayerRepo = new MemorySpatialLayerRepository();
  c.spatialFeatureRepo = new MemorySpatialFeatureRepository();
  c.providerRepo = new MemoryProviderRepository();
  c.geocodingJobRepo = new MemoryGeocodingJobRepository();

  // Application use cases
  c.manageGeocodingResults = new ManageGeocodingResultsUseCase(c.geocodingResultRepo);
  c.manageRoutes = new ManageRoutesUseCase(c.routeRepo);
  c.managePoi = new ManagePointsOfInterestUseCase(c.poiRepo);
  c.manageIsolines = new ManageIsolinesUseCase(c.isolineRepo);
  c.manageGeofenceZones = new ManageGeofenceZonesUseCase(c.geofenceZoneRepo);
  c.manageSpatialLayers = new ManageSpatialLayersUseCase(c.spatialLayerRepo);
  c.manageSpatialFeatures = new ManageSpatialFeaturesUseCase(c.spatialFeatureRepo);
  c.manageProviders = new ManageProvidersUseCase(c.providerRepo);
  c.manageGeocodingJobs = new ManageGeocodingJobsUseCase(c.geocodingJobRepo);

  // Presentation controllers
  c.geocodingController = new GeocodingController(c.manageGeocodingResults);
  c.routingController = new RoutingController(c.manageRoutes);
  c.poiController = new PoiController(c.managePoi);
  c.isolineController = new IsolineController(c.manageIsolines);
  c.geofenceController = new GeofenceController(c.manageGeofenceZones);
  c.spatialLayerController = new SpatialLayerController(c.manageSpatialLayers);
  c.spatialFeatureController = new SpatialFeatureController(c.manageSpatialFeatures);
  c.providerController = new ProviderController(c.manageProviders);
  c.geocodingJobController = new GeocodingJobController(c.manageGeocodingJobs);
  c.healthController = new HealthController(config.serviceName);

  return c;
}
