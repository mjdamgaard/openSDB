
import {
    DBRequestManager,
} from "/UPA_scripts.php?id=t1";
import {
    ContentLoader,
} from "/UPA_scripts.php?id=t2";




export var upaCL = new ContentLoader(
    "ColumnBasedSDBInterface",
    /* Initial HTML */
    '<div id="upa1" class="container sdb-interface-app">' +
        '<<ColumnGroup>>' +
    '</div>'
);
export var columnGroupCL = new ContentLoader(
    "ColumnGroup",
    /* Initial HTML */
    '<div class="container app-column-group">' +
        '<<Column>>' +
    '</div>',
    upaCL
);
columnGroupCL.inwardCallbacks.push(function($ci, data, parentCLArr) {
    switch (data.termID.substring(0, 1)) {
        case "c":
            $ci.find('.placeholder').attr("data-key", "CategoryColumn");
            break;
        default:
            throw (
                "Term type '" + data.termID.substring(0, 1) +
                "' has not been implemented yet"
            );
    }
});

export var columnCL = new ContentLoader(
    "Column",
    /* Initial HTML */
    '<div class="container app-column">' +
        "<<ColumnHeader>>" +
        "<<ColumnMain>>" +
        // "<<ColumnFooter>>" +
    '</div>',
    columnGroupCL
);

export var columnHeaderCL = new ContentLoader(
    "ColumnHeader",
    /* Initial HTML */
    '<header class="container">' +
        '<<TabNavList>>' +
    '</header>',
    columnCL
);
export var columnMainCL = new ContentLoader(
    "ColumnMain",
    /* Initial HTML */
    '<main class="container"></main>',
    columnCL
);

export var tabNavListCL = new ContentLoader(
    "TabNavList",
    /* Initial HTML */
    '<ul class="nav nav-tabs"></ul>',
    upaCL
);




columnCL.inwardCallbacks.push(function($ci, data, parentCLArr) {
    $ci.data("page-spec-store", {})
        .on("add-page", function(event, tabTitle, contentKey, pageData) {
            let pageCL = columnCL.getRelatedContentLoader(
                contentKey, parentCLArr
            );
            $(this).data("page-spec-store")[tabTitle] =
                {cl:pageCL, data:pageData};
            return false;
        })
        .on("open-page", function(event, tabTitle) {
            let $this = $(this);
            let pageSpec = $this.data("page-spec-store")[tabTitle];
            $(this).children('.CI.ColumnMain')
                .trigger("open-page", [tabTitle, pageSpec.cl, pageSpec.data]);
            return false;
        })
        .on("close-page", function(event, tabTitle) {
            $(this).children('.CI.ColumnMain')
                .trigger("open-page", [tabTitle]);
            return false;
        })
        .on("add-tab", function(event, tabTitle) {
            $(this).children('.CI.ColumnHeader')
                .trigger("add-tab", [tabTitle]);
            return false;
        })
        .on("activate-tab", function(event, tabTitle) {
            $(this).children('.CI.ColumnHeader')
                .trigger("activate-tab", [tabTitle]);
            return false;
        })
        .on("add-tab-and-page", function(
            event, tabTitle, contentKey, pageData
        ) {
            $(this)
                .trigger("add-page", [tabTitle, contentKey, pageData])
                .trigger("add-tab", [tabTitle]);
            return false;
        })
        .on("open-tab-and-page", function(event, tabTitle) {
            $(this)
                .trigger("activate-tab", [tabTitle])
                .trigger("open-page", [tabTitle]);
            return false;
        })
        .on("tab-selected", function(event, tabTitle) {
            $(this).trigger("open-page", [tabTitle]);
            return false;
        });
});




columnHeaderCL.inwardCallbacks.push(function($ci, data, parentCLArr) {
    $ci
        .on("add-tab", function(event, tabTitle) {
            $(this).find('.CI.TabNavList')
                .trigger("add-tab", [tabTitle]);
            return false;
        })
        .on("activate-tab", function(event, tabTitle) {
            $(this).find('.CI.TabNavList')
                .trigger("activate-tab", [tabTitle]);
            return false;
        });
});


tabNavListCL.inwardCallbacks.push(function($ci, data, parentCLArr) {
    $ci
        .on("add-tab", function(event, tabTitle) {
            let $newTab = $(this).append(
                    '<li data-title="' + tabTitle + '"> <a href="#">' +
                    tabTitle + '</a> </li>'
                )
                .children(':last-child');
            $newTab.on("click", function() {
                $(this)
                    .trigger("activate-tab", [tabTitle])
                    .trigger("tab-selected", [tabTitle]);
                return false;
            });
            return false;
        })
        .on("activate-tab", function(event, tabTitle) {
            $(this).children('li')
                .removeClass("active")
                .filter('[data-title="' + tabTitle + '"]')
                .addClass("active");
            return false;
        });
});


columnMainCL.inwardCallbacks.push(function($ci, data, parentCLArr) {
    $ci.data("open-pages-title-arr", [])
        .on("open-page", function(event, tabTitle, pageCL, pageData) {
            let $this = $(this);
            if ($this.data("open-pages-title-arr").includes(tabTitle)) {
                $this.children().hide();
                $this.children('[data-title="' + tabTitle +'"]').show();
            } else {
                $this.data("open-pages-title-arr").push(tabTitle);
                $this.children().hide();
                pageCL.loadAppended($this, pageData, parentCLArr);
                $this.children(':last-child').attr("data-title", tabTitle);
            }
            return false;
        })
        .on("close-page", function(event, tabTitle) {
            let $this = $(this);
            let titleArr = $this.data("open-pages-title-arr");
            titleArr[titleArr.indexOf(tabTitle)] = null;
            $this.children('[data-title="' + tabTitle +'"]').remove();
            return false;
        })
});





export var pageFieldCL = new ContentLoader(
    "PageField",
    /* Initial HTML */
    '<div></div>',
    columnCL
);
pageFieldCL.inwardCallbacks.push(function($ci, data, parentCLArr) {
    $ci.data('db-request-manager', new DBRequestManager())
        .on("query-db", function(event, reqData, cacheKey, callback) {
            let $this = $(this);
            let dbReqManager = $this.data('db-request-manager');
            dbReqManager.query($this, reqData, cacheKey, callback);
            return false;
        })
        .on("append-cis", function(event, cl, clDataArr, selector) {
            let $obj = (typeof selector === "undefined") ?
                $(this) : $(this).find(selector);
            let len = clDataArr.length;
            for (let i = 0; i < len; i++) {
                cl.loadAppended($obj, clDataArr[i]);
            }
            return false;
        });
        // TODO: add a prepend-cis event also, after having debugged.
});
export var termListCL = new ContentLoader(
    "TermList",
    /* Initial HTML */
    '<<PageField>>',
    columnCL
);
termListCL.outwardCallbacks.push(function($ci, data, parentCLArr) {
    $ci.append('<ul class="container"></ul>');
});
termListCL.inwardCallbacks.push(function($ci, data, parentCLArr) {
    $ci
        .on("append-elements", function(event, elemCL, elemDataArr) {
            let $list = $(this).children('ul, ol');
            let len = elemDataArr.length;
            for (let i = 0; i < len; i++) {
                elemCL.loadAppended($list, elemDataArr[i]);
            }
            return false;
        })
        .on("empty", function(event, elemDataArr, elemCL) {
            $(this).children('ul, ol').empty();
            return false;
        });
});




export var extensibleTermListCL = new ContentLoader(
    "ExtensibleTermList",
    /* Initial HTML */
    '<<TermList>>',
    columnCL
);



export var supercategoryPageCL = new ContentLoader(
    "SupercategoryPage",
    /* Initial HTML */
    '<<Column>>',
    columnCL
);
supercategoryPageCL.outwardCallbacks.push(function($ci, data, parentCLArr) {
    $ci.trigger(
        "add-tab-and-page",
        ["Defining supercategories", "DefSuperCatsPage", data]
    );
    $ci.trigger("open-tab-and-page", ["Defining supercategories"]);
    // open the "DefSuperCatsPage" tab as the default one.
    // TODO
});

export var defSuperCatsPageCL = new ContentLoader(
    "DefSuperCatsPage",
    /* Initial HTML */
    '<<ExtensibleTermList>>',
    columnCL
);


// test.
export var mainPageCL = new ContentLoader(
    "MainPage",
    /* Initial HTML */
    '<div></div>',
    columnCL
);
mainPageCL.inwardCallbacks.push(function($ci, data, parentCLArr) {
    $ci.prepend(
        '<span>Hello, I will be a main page generated from: ' +
        JSON.stringify(data)
    );
});

export var categoryColumnCL = new ContentLoader(
    "CategoryColumn",
    /* Initial HTML */
    '<<Column>>',
    columnGroupCL
);


categoryColumnCL.outwardCallbacks.push(function($ci, data, parentCLArr) {
    var pageData = "Supercategories";
    $ci.trigger(
        "add-tab-and-page", ["Supercategories", "MainPage", pageData]
    );
    pageData = "Subcategories";
    $ci.trigger(
        "add-tab-and-page", ["Subcategories", "MainPage", pageData]
    );
    pageData = "Elements";
    $ci.trigger(
        "add-tab-and-page", ["Elements", "MainPage", pageData]
    );
    // open the "Subcategories" tab as the default one.
    $ci.trigger("open-tab-and-page", ["Subcategories"]);
});
