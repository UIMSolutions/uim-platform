/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.services.visibility_service;

// import uim.platform.html_repository.domain.types;
// import uim.platform.html_repository.domain.entities.html_app;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
struct VisibilityService {
  // Check if an app is accessible from a given space
  static bool isAccessible(HtmlApp app, SpaceId requestingSpace) {
    // Public apps are accessible from any space
    if (app.visibility == AppVisibility.public_)
      return true;
    // Private apps are only accessible from the same space
    return app.spaceId == requestingSpace;
  }

  // Check if an app can be shared (must be public)
  static bool canShare(HtmlApp app) {
    return app.visibility == AppVisibility.public_ && app.status == AppStatus.active;
  }

  // Check if app is in a valid state for deployment
  static bool canDeploy(HtmlApp app) {
    return app.status == AppStatus.active;
  }

  // Check if an app can be accessed at runtime
  static bool canServe(HtmlApp app) {
    return app.status == AppStatus.active && app.activeVersionId.length > 0;
  }
}
