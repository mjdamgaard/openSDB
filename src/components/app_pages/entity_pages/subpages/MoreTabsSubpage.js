import {useState, useMemo, useContext, useCallback} from "react";
import {useDispatch} from "../../../../hooks/useDispatch.js";

import {basicEntIDs} from "../../../../entity_ids/basic_entity_ids.js";

import {SubpagesWithTabs} from "./SubpagesWithTabs.js";
import {EntityList} from "../../../entity_lists/EntityList.js";
import {ScaleReference} from "../../../entity_refs/EntityReference.js";
import {
  TabEntityElement
} from "../../../entity_lists/elements/TabEntityElement.js";



export const MoreTabsSubpage = ({tabScaleKeysJSON}) => {
  const tabScaleKeys = JSON.parse(tabScaleKeysJSON ?? "[]");

  const getPageCompFromID = useCallback(tabID => {
    const scaleKey = tabScaleKeys[tabID];
    return (
      [EntityList, {
        scaleKeyJSON: JSON.stringify(scaleKey), lo: 4,
        ElemComp: TabEntityElement,
      }]
    );
  }, [tabScaleKeysJSON]);

  const initTabsJSON = JSON.stringify(tabScaleKeys.map((scaleKey, ind) => {
    const objID = scaleKey[0];
    const relID = scaleKey[1]; 
    return [ind, undefined]
  }));
  const getTabTitleFromID = useCallback((tabID, callback) => {
    const scaleKey = tabScaleKeys[tabID];
    const objID = scaleKey[0];
    const relID = scaleKey[1]; 
    callback(<ScaleReference objID={objID} relID={relID} />);
  }, [tabScaleKeysJSON]);

  return (
    <SubpagesWithTabs
      initTabsJSON={[initTabsJSON]}
      getPageCompFromID={getPageCompFromID}
      getTabTitleFromID={getTabTitleFromID}
      tabBarHeader="Tab lists"
    />
  );
};

