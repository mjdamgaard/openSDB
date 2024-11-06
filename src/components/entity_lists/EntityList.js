import {useState, useMemo, useContext} from "react";

import {DataFetcher} from "../../../classes/DataFetcher";
import {EntityReference} from "../../entity_refs/EntityReference";
import {EntityInfoPage} from "./subpages/InfoPage";
import {DropdownMenu} from "../../menus/DropdownMenu";
import {PagesWithTabs} from "../tabs/PagesWithTabs";

/* Placeholders */
const OpenedTabList = () => <template></template>;
const SettingsMenu = () => <template></template>;
const SubmitEntityMenu = () => <template></template>;

// TODO: Import from one location instead:
const CLASSES_CLASS_ID = "4";
const USEFUL_RELATIONS_REL_ID = "19";


export const EntityList = ({scaleKey, userID}) => {
  userID ??= "1"; // (TODO: Remove.)

  // scaleKey = scaleID | [relID, objID, qualID?].
  const [state, setState] = useState({
    entList: null,
  });
  const {scaleID, entList} = state;

  // If the entity list is ready, return the entity list.
  if (Array.isArray(entList)) {
    return (
      <div className="entity-list">
        {JSON.stringify(entList)}
      </div>
    );
  }
  // If it is fetching, return nothing.
  if (entList === "fetching") {
    return <></>;
  }

  // Else if scaleID is provided, query for the entity list.
  if (typeof scaleKey === "number") {
    let scaleID = scaleKey;
    let userID = "1";
    DataFetcher.fetchEntityList(
      userID, scaleID, (entList) => {
        setState(prev => {
          return {
            ...prev,
            entList: entList,
          };
        });
      }
    );
    setState(prev => {
      return {
        ...prev,
        entList: "fetching",
      };
    });
  }
  // Else...
  else {
    let scaleHash = "TODO: Get hash from a function...";
    let userID = "1";
    DataFetcher.fetchEntityListFromHash(
      userID, scaleHash, (entList, scaleID) => {
        setState(prev => {
          return {
            ...prev,
            entList: entList,
          };
        });
      }
    );
    setState(prev => {
      return {
        ...prev,
        entList: "fetching",
      };
    });
  }
  
  return <></>;
};
