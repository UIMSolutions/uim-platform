module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.in_memory_site_repo;
import infrastructure.persistence.in_memory_page_repo;
import infrastructure.persistence.in_memory_section_repo;
import infrastructure.persistence.in_memory_tile_repo;
import infrastructure.persistence.in_memory_catalog_repo;
import infrastructure.persistence.in_memory_provider_repo;
import infrastructure.persistence.in_memory_role_repo;
import infrastructure.persistence.in_memory_theme_repo;
import infrastructure.persistence.in_memory_menu_item_repo;
import infrastructure.persistence.in_memory_translation_repo;

// Use Cases
import application.use_cases.manage_sites;
import application.use_cases.manage_pages;
import application.use_cases.manage_sections;
import application.use_cases.manage_tiles;
import application.use_cases.manage_catalogs;
import application.use_cases.manage_providers;
import application.use_cases.manage_roles;
import application.use_cases.manage_themes;
import application.use_cases.manage_menu_items;
import application.use_cases.manage_translations;

// Controllers
import presentation.http.site_controller;
import presentation.http.page_controller;
import presentation.http.section_controller;
import presentation.http.tile_controller;
import presentation.http.catalog_controller;
import presentation.http.provider_controller;
import presentation.http.role_controller;
import presentation.http.theme_controller;
import presentation.http.menu_item_controller;
import presentation.http.translation_controller;
import presentation.http.health_controller;

/// Dependency injection container — wires all layers together.
struct Container
{
    // Repositories (driven adapters)
    InMemorySiteRepository siteRepo;
    InMemoryPageRepository pageRepo;
    InMemorySectionRepository sectionRepo;
    InMemoryTileRepository tileRepo;
    InMemoryCatalogRepository catalogRepo;
    InMemoryProviderRepository providerRepo;
    InMemoryRoleRepository roleRepo;
    InMemoryThemeRepository themeRepo;
    InMemoryMenuItemRepository menuItemRepo;
    InMemoryTranslationRepository translationRepo;

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
    c.siteRepo = new InMemorySiteRepository();
    c.pageRepo = new InMemoryPageRepository();
    c.sectionRepo = new InMemorySectionRepository();
    c.tileRepo = new InMemoryTileRepository();
    c.catalogRepo = new InMemoryCatalogRepository();
    c.providerRepo = new InMemoryProviderRepository();
    c.roleRepo = new InMemoryRoleRepository();
    c.themeRepo = new InMemoryThemeRepository();
    c.menuItemRepo = new InMemoryMenuItemRepository();
    c.translationRepo = new InMemoryTranslationRepository();

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
    c.healthController = new HealthController();

    return c;
}
