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
import QmlAppComponents 0.1
import "./ListComponent/"

FocusScope {
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

    Item {
        id: navBackwardBtn
        width: appStyle.relativeXBasedOnFHD(appStyle.mediaListHPadding)
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        KeyNavigation.right: navForwardBtn
        //focus: true

        Keys.onReturnPressed: {
            folderListComponent.movePage(folderListComponent.backward);
        }
        Keys.onEnterPressed: {
            folderListComponent.movePage(folderListComponent.backward);
        }

        Rectangle {
            anchors.fill: parent
            radius: width/2
            color: "white"
            opacity: 0.3
            visible: navBackwardBtn.activeFocus
        }

        Canvas {
            id: leftArrow
            width: parent.width
            height: parent.height
            opacity: 0.4
            onPaint: {
                var ctx = getContext("2d");

                ctx.lineWidth = 1;
                ctx.strokeStyle = appStyle.appColor.selectMenuBackground

                ctx.fillStyle = appStyle.appColor.selectMenuBackground
                ctx.beginPath();
                ctx.moveTo(leftArrow.width / 5 * 4, leftArrow.height * 0.35);
                ctx.lineTo(leftArrow.width / 5, leftArrow.height * 0.5);
                ctx.lineTo(leftArrow.width / 5 * 4, leftArrow.height * 0.65);
                ctx.lineTo(leftArrow.width / 5 * 4, leftArrow.height * 0.6);
                ctx.lineTo(leftArrow.width / 5 * 2, leftArrow.height * 0.5);
                ctx.lineTo(leftArrow.width / 5 * 4, leftArrow.height * 0.4);
                ctx.closePath();
                ctx.fill();
                ctx.stroke();

            }
        }

        MouseArea {
            id: navBackwardBtnArea
            anchors.fill: parent
            state: "released"
            enabled: folderListComponent.isHighlightFirst ? false : true
            onPressed: {
                navBackwardBtnArea.state = "pressed";
            }
            onClicked: {
                folderListComponent.movePage(folderListComponent.backward);
            }
            onPressAndHold: {
                folderListComponent.moveFast(folderListComponent.backward);
            }
            onReleased: {
                if(enabled) {
                    navBackwardBtnArea.state = "released";
                    folderListComponent.moveStop();
                }
            }
            onEnabledChanged: {
                if(enabled)
                    navBackwardBtnArea.state = "released"
                else
                    navBackwardBtnArea.state = "disabled"
            }

            states: [
                State {
                    name: "pressed";
                    PropertyChanges {target: leftArrow; opacity: 1.0}
                },
                State {
                    name: "released";
                    PropertyChanges {target: leftArrow; opacity: 0.4}
                },
                State {
                    name: "disabled";
                    PropertyChanges {target: leftArrow; opacity: 0.1}
                }
            ]

            transitions: [
                Transition {
                    NumberAnimation {
                        target: leftArrow; property: "opacity"
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            ]
        }
    }


    HorizentalListComponent {
        id: folderListComponent
        anchors.left: navBackwardBtn.right
        anchors.right: navForwardBtn.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        focus: true

        elementWidth: height * 0.9
        elementHeight: height * 0.9

        spacing: 30

        objectName:  "HorizentalListComponent"
        DebugBackground {}

        clickAcion: function(index){
            root.notifyFolderClicked(folderList[index]);
        }

    }

    Item {
        id: navForwardBtn
        width: appStyle.relativeXBasedOnFHD(appStyle.mediaListHPadding)
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        KeyNavigation.left: navBackwardBtn
        Keys.onReturnPressed: {
            folderListComponent.movePage(folderListComponent.forward);
        }
        Keys.onEnterPressed: {
            folderListComponent.movePage(folderListComponent.forward);
        }

        Rectangle {
            anchors.fill: parent
            radius: width/2
            color: "white"
            opacity: 0.3

            visible: navForwardBtn.activeFocus
        }

        Canvas {
            id: rightArrow
            width: parent.width
            height: parent.height
            opacity: 0.4
            onPaint: {
                var ctx = getContext("2d");

                ctx.lineWidth = 1;
                ctx.strokeStyle = appStyle.appColor.selectMenuBackground

                ctx.fillStyle = appStyle.appColor.selectMenuBackground
                ctx.beginPath();
                ctx.moveTo(rightArrow.width / 5, rightArrow.height * 0.35);
                ctx.lineTo(rightArrow.width / 5 * 4, rightArrow.height * 0.5);
                ctx.lineTo(rightArrow.width / 5, rightArrow.height * 0.65);
                ctx.lineTo(rightArrow.width / 5, rightArrow.height * 0.6);
                ctx.lineTo(rightArrow.width / 5 * 3, rightArrow.height * 0.5);
                ctx.lineTo(rightArrow.width / 5, rightArrow.height * 0.4);
                ctx.closePath();
                ctx.fill();
                ctx.stroke();

            }
        }

        MouseArea {
            id: navForwardBtnArea
            anchors.fill: parent
            state: "released"
            enabled: folderListComponent.isHighlightLast ? false : true
            onPressed: {
                navForwardBtnArea.state = "pressed";
            }
            onClicked: {
                folderListComponent.movePage(folderListComponent.forward);
            }
            onPressAndHold: {
                folderListComponent.moveFast(folderListComponent.forward);
            }
            onReleased: {
                if(enabled) {
                    navForwardBtnArea.state = "released";
                    folderListComponent.moveStop();
                }
            }
            onEnabledChanged: {
                if(enabled) navForwardBtnArea.state = "released"
                else navForwardBtnArea.state = "disabled"
            }

            states: [
                State {
                    name: "pressed";
                    PropertyChanges {target: rightArrow; opacity: 1.0}
                },
                State {
                    name: "released";
                    PropertyChanges {target: rightArrow; opacity: 0.4}
                },
                State {
                    name: "disabled";
                    PropertyChanges {target: rightArrow; opacity: 0.1}
                }
            ]

            transitions: [
                Transition {
                    NumberAnimation {
                        target: rightArrow; property: "opacity"
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            ]
        }
    }


}
