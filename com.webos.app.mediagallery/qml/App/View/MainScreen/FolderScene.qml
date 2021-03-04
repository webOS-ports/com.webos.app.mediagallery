/* @@@LICENSE
 *
 * Copyright (c) 2021 LG Electronics, Inc.
 *
 * Confidential computer software. Valid license from LG required for
 * possession, use or copying. Consistent with FAR 12.211 and 12.212,
 * Commercial Computer Software, Computer Software Documentation, and
 * Technical Data for Commercial Items are licensed to the U.S. Government
 * under vendor's standard commercial license.
 *
 * LICENSE@@@ */

import QtQuick 2.6
import QmlAppComponents 0.1
import "./ListComponent/"

Item {
    id: root

    objectName: "folderListScene"
    DebugBackground {}
    clip: true

    signal notifyFolderClicked(var folderName);

    property var folderList: []

    Connections {
        target: service.mediaIndexer
        onListUpdated: {
            appLog.debug("FolderScene :: connection with media indexer :: onListUpdated");
            folderList = list;

            if(folderList.length == 0) {
                appLog.debug("FolderList is empty. Clean current folder info and files");
                currentFolder = "";
            }

            //Set default currentFolder value if mode is changed
            if(service.mediaIndexer.isOnUpdating) {
                appLog.debug("----- Waiting media list update ends");
            }

            folderListComponent.updateListModel(folderList);

//            if(!checkStartPointValid() &&
//                    isModeChanged &&
//                    folderList.length > 0) currentFolder = folderList[0];
//                    isModeChanged &&
            if(!checkStartPointValid() &&
                    folderList.length > 0) {
                appLog.debug("Set first folder as start point");
                currentFolder = folderList[0];
                startFolderInfo[currentMode] = currentFolder;
            }
        }
    }

    function setFolderListAsEmpty() {
        folderList = [];
        folderListComponent.updateListModel(folderList);
    }

    function checkStartPointValid(){
        if(startFolderInfo[currentMode] == "") {
            appLog.debug("StartFolder currentMode " + currentMode + " null ");
            return false;
        }

        const found = folderList.findIndex(element => element === startFolderInfo[currentMode]);

        appLog.debug("CheckStartPointValid() called :: found = " + found);

        if(found === -1) {
            appLog.debug("Start folder cannot be found : folder name = " + startFolderInfo[currentMode]);
            return false;
        }
        currentFolder = startFolderInfo[currentMode];
        folderListComponent.setStartIndex(found);

        return true;
    }

    Rectangle {
        anchors.fill:parent
        color: "black"
        opacity: 0.3
    }

    HorizentalListComponent {
        id: folderListComponent
        anchors.fill: parent
        anchors.leftMargin: appStyle.relativeXBasedOnFHD(30)

        elementWidth: height * 0.8
        elementHeight: height * 0.8

        spacing: 30

        objectName:  "HorizentalListComponent"
        DebugBackground {}

        clickAcion: function(index){
            root.notifyFolderClicked(folderList[index]);
        }
    }


}
