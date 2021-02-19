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

import QtQuick 2.4
import QmlAppComponents 0.1
import "./ListComponent/"
/*
-- Scene ----- MediaList --- GridView
I                          I
I                          -- DetailView
*/
Item {
    id: root

    objectName: "mediaListScene"
    DebugBackground {}
    clip: true

// TODO: maybe we need current file location
//    property int currentPlaylistIndex: 0

    property var currentFolder: mainScreenView.currentFolder
    property var fileListForCurrentFolder: []

    onCurrentFolderChanged: {
//        if(currentFolder !== "") {
            var list = service.mediaIndexer.getFileListOfFolder(currentFolder);
            fileListForCurrentFolder = list;
            fileList.updateListModel(fileListForCurrentFolder);
//        }
    }


    DelayRequestListcomponent {
        id: fileList
        anchors.fill: parent
//        width: root.width
//        height: root.height

        gridViewWidth: width / 4
        gridViewHeight: width / 4
        delayLoadingTime: 600
        componentLayout: "ThumbnailImage.qml"
        componentParam: {"thumbnailUrl":"thumbnail"}
        componentSize: {"width": gridViewWidth, "height": gridViewHeight}

        clickAction: function(index) {
            appLog.debug("file index clicked : " + fileListForCurrentFolder[index].file_path);
            var filePath = fileListForCurrentFolder[index].file_path;
            switch(appMode) {
            case stringSheet.category.image:
                appLog.debug("call image viewer");
                break;
            case stringSheet.category.video:
                appLog.debug("call video viewer");
                break;
            case stringSheet.category.audio:
                appLog.debug("call audio player");
                service.webOSService.singleCallService.launchAppWithParam(
                            stringSheet.viewerApps.audio,
                            {"appMode":stringSheet.category.audio,
                             "folder": currentFolder,
                             "fileIndex": index,
                             "fileUrl":filePath})
                break;
            }
        }
    }

}
