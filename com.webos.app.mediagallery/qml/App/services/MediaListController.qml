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
import WebOSServices 1.0
import QmlAppComponents 0.1
import Eos.Controls 0.1
import "../commonComponents"

Item {
    id: root
    objectName: "mediaListController"

    property string currentMode: appRoot.appMode // 0:image, 1: video, 2: audio
    property var listType: "imageList"
    signal fileTreeUpdated(var list);

    property var fileTreeDictionary: ({"all":[]})

    function getFileListOfFolder(folderName) {
        if(folderName === "") return [];

        var fileList = fileTreeDictionary[folderName];
        if(fileList == undefined){
            appLog.error("ERROR: Unknown folderName = " + folderName);
            fileList = [];
        }
        return fileList;
    }

    function getFolderFileFromPath(path) {
        var splitArray = path.replace('file:///','').split('/');
        var pathArray = [splitArray[splitArray.length - 2], splitArray[splitArray.length-1]];

        return { folder: pathArray[0],
                 file: pathArray[1]    };
    }

    Connections {
        target: mediaIndexerService
        onMediaListChanged: {
            appLog.debug("MeidaListController get mediaList length = " + mediaList.length);
            appLog.debug("MeidaListController isModeChanged = " + isModeChanged);

            //TODO : ********************  ModeChange TTTTTTT
            if(isModeChanged) fileTreeDictionary= {"all":[]}

            for (var i = 0 ; i < mediaList.length; i++) {
                if(mediaList[i].file_path == undefined) {
                    appLog.warn(i + "th data doesn't have file path : " + Utils.listProperty(list[i]));
                    continue;
                }

                var {folder,file} = getFolderFileFromPath(mediaList[i].file_path);
                var fileList = [];

                //mediaList: put default data if value is not exist
                if(mediaList[i].thumbnail == undefined) {
                    if(appRoot.appMode == stringSheet.category.image) {
                        mediaList[i].thumbnail = mediaList[i].file_path
                    } else {
                        mediaList[i].thumbnail = "EmptyThumbnail";
                    }
                }

                if(mediaList[i].title == undefined) {
                    if(appRoot.appMode == stringSheet.category.image) {
                        mediaList[i].title = file
                    } else {
                        mediaList[i].title = "No Title Info";
                    }
                }

                if(folder in fileTreeDictionary) {
                    fileList = fileTreeDictionary[folder];

                    //TODO: Need to check how to deal when same file data is received

                    //Idea1: Use duplicate check dictionary and folderfilelist seperately

                    var exist = -1;
                    for(var flist = 0 ; flist < fileList.length; flist ++) {
                        if(fileList[flist]["file_path"] == mediaList[i].file_path) exist = flist;
                    }
                    if(exist == -1) fileList.push(mediaList[i]); // push new item
                    else fileList[exist] = mediaList[i]; // modify
                } else {
                    fileList.push(mediaList[i]);
                    fileTreeDictionary[folder] = fileList;
                }

                var allList = fileTreeDictionary["all"];
                allList.push(mediaList[i]);
            }

            var folders = (Object.keys(fileTreeDictionary)).filter(value => value !== "all")
            root.fileTreeUpdated(folders);
        }
    }


}
