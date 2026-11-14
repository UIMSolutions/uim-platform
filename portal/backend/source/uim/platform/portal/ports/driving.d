/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.driving;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// Bundle of all driving ports. Presentation adapters (REST, OData, CLI, GUI)
/// depend on this bundle only — never on concrete interactors or repositories.
struct PortalPorts {
  IManageSitesUseCase sites;
  IManagePagesUseCase pages;
  IManageSectionsUseCase sections;
  IManageTilesUseCase tiles;
  IManageCatalogsUseCase catalogs;
  IManageProvidersUseCase providers;
  IManageRolesUseCase roles;
  IManageThemesUseCase themes;
  IManageMenuItemsUseCase menuItems;
  IManageTranslationsUseCase translations;
  ISyncProvidersUseCase synchronizer;
  IPortalStatisticsService statistics;
  ILaunchpadService launchpad;
}
