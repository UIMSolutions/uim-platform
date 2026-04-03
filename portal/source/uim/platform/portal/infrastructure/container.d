/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.infrastructure.container;

import uim.platform.portal.infrastructure.config;

// Repositories
import uim.platform.portal.infrastructure.persistence.memory.site_repo;
import uim.platform.portal.infrastructure.persistence.memory.page_repo;
import uim.platform.portal.infrastructure.persistence.memory.section_repo;
import uim.platform.portal.infrastructure.persistence.memory.tile_repo;
import uim.platform.portal.infrastructure.persistence.memory.catalog_repo;
import uim.platform.portal.infrastructure.persistence.memory.provider_repo;
import uim.platform.portal.infrastructure.persistence.memory.role_repo;
import uim.platform.portal.infrastructure.persistence.memory.theme_repo;
import uim.platform.portal.infrastructure.persistence.memory.menu_item_repo;
import uim.platform.portal.infrastructure.persistence.memory.translation_repo;

// Use Cases
import uim.platform.portal.application.usecases.manage_sites;
import uim.platform.portal.application.usecases.manage_pages;
import uim.platform.portal.application.usecases.manage_sections;
import uim.platform.portal.application.usecases.manage_tiles;
import uim.platform.portal.application.usecases.manage_catalogs;
import uim.platform.portal.application.usecases.manage_providers;
import uim.platform.portal.application.usecases.manage_roles;
import uim.platform.portal.application.usecases.manage_themes;
import uim.platform.portal.application.usecases.manage_menu_items;
import uim.platform.portal.application.usecases.manage_translations;

// Controllers
import uim.platform.identity_authentication.presentation.http.site;
import uim.platform.identity_authentication.presentation.http.page;
import uim.platform.identity_authentication.presentation.http.section;
import uim.platform.identity_authentication.presentation.http.tile;
import uim.platform.identity_authentication.presentation.http.catalog;
import uim.platform.identity_authentication.presentation.http.provider;
import uim.platform.identity_authentication.presentation.http.role;
import uim.platform.identity_authentication.presentation.http.theme;
import uim.platform.identity_authentication.presentation.http.menu_item;
import uim.platform.identity_authentication.presentation.http.translation;
import uim.platform.identity_authentication.presentation.http.health;

/// Dependency injection container — wires all layers together.
struct Container
{
  // Repositories (driven adapters)
  MemorySiteRepository siteRepo;
  MemoryPageRepository pageRepo;
  MemorySectionRepository sectionRepo;
  MemoryTileRepository tileRepo;
  MemoryCatalogRepository catalogRepo;
  MemoryProviderRepository providerRepo;
  MemoryRoleRepository roleRepo;
  MemoryThemeRepository themeRepo;
  MemoryMenuItemRepository menuItemRepo;
  MemoryTranslationRepository translationRepo;

  // Use cases (application layer)
  ManageSitesUseCase manageSites;
  ManagePagesUseCase managePages;
  ManageSectionsUseCase manageSections;
  ManageTilesUseCase manageTiles;
  ManageCatalogsUseCase manageCatalogs;
  ManageProvidersUseCase manageProviders;
  ManageRolesUseCase manageRoles;
  ManageThemesUseCase manageThemes;
  ManageMenuItemsUseCase manageMenuItems;
  ManageTranslationsUseCase manageTranslations;

  // Controllers (driving adapters)
  SiteController siteController;
  PageController pageController;
  SectionController sectionController;
  TileController tileController;
  CatalogController catalogController;
  ProviderController providerController;
  RoleController roleController;
  ThemeController themeController;
  MenuItemController menuItemController;
  TranslationController translationController;
  HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config)
{
  Container c;

  // Infrastructure adapters
  c.siteRepo = new MemorySiteRepository();
  c.pageRepo = new MemoryPageRepository();
  c.sectionRepo = new MemorySectionRepository();
  c.tileRepo = new MemoryTileRepository();
  c.catalogRepo = new MemoryCatalogRepository();
  c.providerRepo = new MemoryProviderRepository();
  c.roleRepo = new MemoryRoleRepository();
  c.themeRepo = new MemoryThemeRepository();
  c.menuItemRepo = new MemoryMenuItemRepository();
  c.translationRepo = new MemoryTranslationRepository();

  // Application use cases
  c.manageSites = new ManageSitesUseCase(c.siteRepo);
  c.managePages = new ManagePagesUseCase(c.pageRepo, c.siteRepo);
  c.manageSections = new ManageSectionsUseCase(c.sectionRepo, c.pageRepo);
  c.manageTiles = new ManageTilesUseCase(c.tileRepo);
  c.manageCatalogs = new ManageCatalogsUseCase(c.catalogRepo);
  c.manageProviders = new ManageProvidersUseCase(c.providerRepo);
  c.manageRoles = new ManageRolesUseCase(c.roleRepo);
  c.manageThemes = new ManageThemesUseCase(c.themeRepo);
  c.manageMenuItems = new ManageMenuItemsUseCase(c.menuItemRepo, c.siteRepo);
  c.manageTranslations = new ManageTranslationsUseCase(c.translationRepo);

  // Presentation controllers
  c.siteController = new SiteController(c.manageSites);
  c.pageController = new PageController(c.managePages);
  c.sectionController = new SectionController(c.manageSections);
  c.tileController = new TileController(c.manageTiles);
  c.catalogController = new CatalogController(c.manageCatalogs);
  c.providerController = new ProviderController(c.manageProviders);
  c.roleController = new RoleController(c.manageRoles);
  c.themeController = new ThemeController(c.manageThemes);
  c.menuItemController = new MenuItemController(c.manageMenuItems);
  c.translationController = new TranslationController(c.manageTranslations);
  c.healthController = new HealthController("portal");

  return c;
}
