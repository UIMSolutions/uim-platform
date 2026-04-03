module uim.platform.xyz.domain.services.content_search;

import std.algorithm : canFind, filter;
import std.array : array;
import std.uni : toLower;

import domain.types;
import domain.entities.content_item;

/// Domain service — simple in-memory content search.
struct ContentSearchService
{
    /// Search content items by keyword in title, body, summary, or tags.
    static ContentItem[] search(ContentItem[] items, string query)
    {
        if (query.length == 0)
            return items;

        string q = query.toLower();

        return items.filter!((ref ContentItem c) {
            if (c.title.toLower().canFind(q))
                return true;
            if (c.summary.toLower().canFind(q))
                return true;
            if (c.body_.toLower().canFind(q))
                return true;
            foreach (ref t; c.tags)
                if (t.toLower().canFind(q))
                    return true;
            return false;
        }).array;
    }
}
