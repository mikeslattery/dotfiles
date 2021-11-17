/*
Type "yj" to copy settings into clipboard
*/
// an example to create a new mapping `ctrl-y`
/*
mapkey('<ctrl-y>', 'Show me the money', function() {
    Front.showPopup('a well-known phrase uttered by characters in the 1996 film Jerry Maguire (Escape to close).');
});
*/

// an example to replace `T` with `gt`, click `Default mappings` to see how `T` works.
// map('gt', 'T');

// an example to remove mapkey `Ctrl-i`
// unmap('<ctrl-i>');

imap('jk', '<Esc>')
imap('<C-Space>', '<Esc>')
aceVimMap('jj', '<Esc>', 'insert');
aceVimMap('<C-Space>', '<Esc>', 'insert');
addSearchAliasX('e', 'wikipedia', 'https://en.wikipedia.org/wiki/', 's', 'https://en.wikipedia.org/w/api.php?action=opensearch&format=json&formatversion=2&namespace=0&limit=40&search=', function(response) {
    return JSON.parse(response.text)[1];
});
mapkey('oe', '#8Open Search with alias e', function() {
    // wikipedia
    Front.openOmnibar({type: "SearchEngine", extra: "e"});
});
mapkey('os', '#8Open Search with alias e', function() {
    // Stack overflow
    Front.openOmnibar({type: "SearchEngine", extra: "s"});
});
/* TODO: conflicts with search history
mapkey('oh', '#8Open Search with alias e', function() {
    // github
    Front.openOmnibar({type: "SearchEngine", extra: "h"});
});
*/
// set theme
settings.theme = `
.sk_theme {
    font-family: Input Sans Condensed, Charcoal, sans-serif;
    font-size: 10pt;
    background: #24272e;
    color: #abb2bf;
}
.sk_theme tbody {
    color: #fff;
}
.sk_theme input {
    color: #d0d0d0;
}
.sk_theme .url {
    color: #61afef;
}
.sk_theme .annotation {
    color: #56b6c2;
}
.sk_theme .omnibar_highlight {
    color: #528bff;
}
.sk_theme .omnibar_timestamp {
    color: #e5c07b;
}
.sk_theme .omnibar_visitcount {
    color: #98c379;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
    background: #303030;
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
    background: #3e4452;
}
#sk_status, #sk_find {
    font-size: 20pt;
}`;
// click `Save` button to make above settings to take effect.</ctrl-i></ctrl-y>
