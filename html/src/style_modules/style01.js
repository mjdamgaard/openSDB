
import {
    sdbInterfaceCL, appColumnCL,
    interfaceHeaderCL, closeButtonCL,
} from "/src/content_loaders/SDBInterfaces.js";
import {
    tabHeaderCL, pagesContainerCL,
} from "/src/content_loaders/PagesWithTabs.js";
import {
    termTitleCL,
} from "/src/content_loaders/Titles.js";
import {

} from "/src/content_loaders/TermPages.js";
import {
    generalTermElementCL,
} from "/src/content_loaders/TermElements.js";
import {
    dropdownButtonBarCL, setHeaderCL
} from "/src/content_loaders/SetDisplays.js";
import {
    ratingElementCL,
} from "/src/content_loaders/Ratings.js";



sdbInterfaceCL.addCSS(
    'height: 100%;' +
    'display: grid;' +
    'grid-template-columns: auto;' +
    'grid-template-rows: 20px auto;' +
    ''
);
interfaceHeaderCL.addCSS(
    'height: 10px;' +
    'background-color: blue;'
);
sdbInterfaceCL.addCSS(
    '& main {' +
        'display: grid;' +
        'grid-template-columns: 60px auto 60px;' +
        'grid-template-rows: auto;' +
    '}'
);
sdbInterfaceCL.addCSS(
    '& .app-column-container {' +
        'display: grid;' +
        'grid-template-columns: auto auto auto;' +
        'grid-template-rows: auto;' +
        'overflow-x: auto;' +
        'overflow-y: hidden;' +
        'white-space: nowrap;' +
        'background-color: #f9fef5;' +
    '}'
);
appColumnCL.addCSS(
    // 'flex-grow: 1;' +
    'overflow: initial;' +
    'white-space: initial;' +
    'display: inline-block;' +
    'margin: 0px 10px;' +
    // 'width: 600px;' +
    'border: 1px solid #DDD;' +
    'border-radius: 8px;' +
    'background-color: #FFF;' +
    ''
);
closeButtonCL.addCSS(
    'padding: 0px 4px;' +
    // 'position: relative;' +
    // 'z-index: 2;' +
    ''
);
tabHeaderCL.addCSS(
    'padding: 4px 0px 0px;' +
    // 'background-color: #f7f7f7;' +
    ''
);
tabHeaderCL.addCSS(
    '& .CI.CloseButton {' +
        "position: absolute;" +
        "z-index: 2;" +
        "right: 1px;" +
        "top: 1px;" +
    '}'
);
tabHeaderCL.addCSS(
    '& ul > li .nav-link {' +
        'pointer-events: none;' +
        'border-bottom: 1px solid #ddd;' +
        'background-color: #fefefe;' +
        // 'box-shadow: 10px 10px 5px lightblue;' +
    '}'
);
tabHeaderCL.addCSS(
    '& ul {' +
        'display: flex;' +
        // 'justify-content: flex-end;' +
        'flex-wrap: wrap-reverse;' +
        'flex-direction: row;' +
        'margin: 0px 0px 0px 2px;' +
    '}'
);
tabHeaderCL.addCSS(
    '& ul > li {' +
        'margin: 2px 1px -1px 0px;' +
    '}'
);
tabHeaderCL.addCSS(
    '& ul > li.active .nav-link {' +
        'border-bottom: 1px solid #fff;' +
        'background-color: #fff;' +
    '}'
);


sdbInterfaceCL.addCSS(
    '& .clickable-text:hover {' +
        'cursor: pointer;' +
        'text-decoration: underline;' +
        'color: blue;' +
    '}'
);



generalTermElementCL.addCSS(
    'border-bottom: 1px solid gray;' +
    // 'border-top: 1px solid gray;' +
    ''
);
ratingElementCL.addCSS(
    'border-bottom: 1px solid gray;' +
    // 'border-top: 1px solid gray;' +
    ''
);




dropdownButtonBarCL.addCSS(
    '&:hover {' +
        'cursor: pointer;' +
        'background-color: #eee;' +
    '}'
);
dropdownButtonBarCL.addCSS(
    'display: flex;' +
    'justify-content: center;'
);
setHeaderCL.addCSS(
    '& .CI.DropdownButtonBar:not(:hover) {' +
        'background-color: #f4f9ff;' +
    '}'
);