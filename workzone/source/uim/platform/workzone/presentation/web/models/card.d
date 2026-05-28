/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.models.card;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
/// Web view-model for a Card integration tile.
struct CardViewModel {
    string id;
    TenantId tenantId;
    string title;
    string subtitle;
    string description;
    string icon;
    string cardTypeLabel;
    bool active;
    string activeLabel;
    string activeCssClass;

    static CardViewModel from(const Card c) {
        return CardViewModel(
            c.id.value, c.tenantId, c.title, c.subtitle, c.description, c.icon,
            labelForType(c.cardType),
            c.active,
            c.active ? "Active" : "Inactive",
            c.active ? "badge-success" : "badge-secondary"
        );
    }

    private static string labelForType(CardType t) {
        final switch (t) {
            case CardType.list:       return "List";
            case CardType.table:      return "Table";
            case CardType.object_:    return "Object";
            case CardType.analytical: return "Analytical";
            case CardType.timeline:   return "Timeline";
            case CardType.calendar:   return "Calendar";
            case CardType.custom:     return "Custom";
        }
    }
}

/// View-model for the card catalogue page.
struct CardListViewModel {
    TenantId tenantId;
    CardViewModel[] items;
    string errorMessage;
    bool hasError() const { return errorMessage.length > 0; }
}
