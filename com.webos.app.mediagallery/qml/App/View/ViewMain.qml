/* @@@LICENSE
*
*      Copyright (c) 2021-2022 LG Electronics, Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* LICENSE@@@ */

import QtQuick 2.6
import Eos.Controls 0.1
import Eos.Style 0.1
import QmlAppComponents 0.1

FocusScope {
    id: root

    property bool isOnModeChanging: false;
    property string currentMode: appRoot.appMode

    function setStartPoint(mode, folder, fileIndex, fileUrl){
        const found = stringSheet.modeView.mode.findIndex(element => element === mode);
        if(found !== -1) {
            appRoot.appMode = mode;
            modeView.setStartPoint(found);
//            mainScreenView.startFolder = folder;
            mainScreenView.startFolderInfo[mode] = folder;
        } else {
            appRoot.appMode = stringSheet.modeView.mode[0];
        }
    }

    Connections {
        target: modeView
        onNotifyModeClicked : {
            appLog.debug("Mode Changed to " + stringSheet.modeView.mode[index]);
            appRoot.appMode = stringSheet.modeView.mode[index];

            //TODO : Search different way to notice mode changing to set currentfolder
            isOnModeChanging = true;
        }
    }

    onCurrentModeChanged: {
        appLog.debug("Detect Mode Change. set the current folder as empty");
        mainScreenView.currentFolder = "";
        mainScreenView.setFolderListAsEmpty();

        //TODO: maybe better way to set focuse mode
        const found = stringSheet.modeView.mode.findIndex(element => element === currentMode);
        if(found !== 1)
            modeView.setStartPoint(found);
    }

    objectName: "viewMain"


    /*
      App Scene Structure.

      App ...... View .....   Scene?

      MediaGallery --- ModeView --- MenuList
                    I            I
                    I            -- MusicListCategory
                    I
                     -- Scene ------ Loading
                    I         I
                    I         ----- MediaList --- GridView
                    I                          I
                    I                          -- DetailView
      */

    ModeView {
        id: modeView
        focus: true
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: appStyle.relativeXBasedOnFHD(appStyle.menuWitdh)

        MouseArea {
            id: modeViewArea
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: {
                mouse.accepted = false;
            }
        }

        objectName: "modeView"
        DebugBackground {}

        KeyNavigation.right: mainScreenView

    }

    MainScreenView {
        id: mainScreenView
        anchors.left: modeView.right
        anchors.leftMargin: appStyle.relativeXBasedOnFHD(appStyle.viewItemSpacing)
        anchors.right: parent.right
        anchors.rightMargin: appStyle.relativeXBasedOnFHD(appStyle.viewItemSpacing)
        anchors.top: modeView.top
        anchors.bottom: parent.bottom

        KeyNavigation.left: modeView
    }
}
