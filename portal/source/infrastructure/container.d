module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.memory.site_repo;
import infrastructure.persistence.memory.page_repo;
import infrastructure.persistence.memory.section_repo;
import infrastructure.persistence.memory.tile_repo;
import infrastructure.persistence.memory.catalog_repo;
import infrastructure.persistence.memory.provider_repo;
import infrastructure.persistence.memory.role_repo;
import infrastructure.persistence.memory.theme_repo;
import infrastructure.persistence.memory.menu_item_repo;
import infrastructure.persistence.memory.translation_repo;

// Use Cases
import application.usecases.manage_sites;
import application.usecases.manage_pages;
import application.usecases.manage_sections;
import application.usecases.manage_tiles;
import application.usecases.manage_catalogs;
import application.usecases.manage_providers;
import application.usecases.manage_roles;
import application.usecases.manage_themes;
import application.usecases.manage_menu_items;
import application.usecases.manage_translations;

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
