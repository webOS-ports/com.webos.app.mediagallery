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
import "./MainScreen"
import QmlAppComponents 0.1


/*
-- Scene ------ Loading
I         I
I         ----- MediaList --- GridView
I                          I
I                          -- DetailView
*/

Item {
    id: root

    objectName: "mainScreenView"

    clip: true

    DebugBackground {}

    property var currentFolder: "";
    property var startFolderInfo: ({})
    property var currentMode: viewMain.currentMode

    onCurrentFolderChanged: {
        appLog.debug("MainScreenView currentFolder " + currentFolder);
    }

    onCurrentModeChanged: {
        root.state = "showList"
    }

    Connections {
        target: folderListScene

        onNotifyFolderClicked: {
            appLog.debug("NotifyFolderClick in MainScreenView :" +folderName);
            currentFolder = folderName;

            startFolderInfo[currentMode] = currentFolder;
            appLog.debug("StartFolder for mode = " + currentMode + " = " + currentFolder);
        }
    }

    Connections {
        target: modeViewArea
        onClicked: {
            if(root.state == "preview")
               root.state = "disappearAnimation";
        }
    }

    function setFolderListAsEmpty () {
        folderListScene.setFolderListAsEmpty();
    }

    FolderScene {
        id: folderListScene
        objectName: "folderListScene"
        height: appStyle.relativeYBasedOnFHD(appStyle.folderListHeight)
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        DebugBackground {}
    }

    Rectangle {
        id: spacingRect

        objectName: "spacingRect"

        height: appStyle.relativeYBasedOnFHD(appStyle.paddingInMainScreen)
        anchors.top: folderListScene.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        color: "transparent"
        DebugBackground {}
    }

    MediaListScene {
        id: mediaListScene

        objectName: "mediaListScene"

        height: appStyle.relativeYBasedOnFHD(appStyle.mediaListHeight)

        anchors.top: spacingRect.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.leftMargin: appStyle.relativeXBasedOnFHD(100)
        anchors.rightMargin: appStyle.relativeXBasedOnFHD(100)

        Rectangle {
            color: "white"
        }

        DebugBackground {}
    }

    property real clickX: 0
    property real clickY: 0

    function showPreview(filePath, x, y) {
        clickX = x + mediaListScene.x;
        clickY = y + mediaListScene.y;

        previewImage.setPreviewSource(filePath);
        root.state = "preview";
    }

    state: "showList"

    states: [
        State {
            name: "preview"
            PropertyChanges { target: previewImage; visible: true }
            PropertyChanges { target: photo; x: previewImage.width * 0.1;
                y:previewImage.height * 0.15;
                width: previewImage.width * 0.8;
                height: previewImage.height * 0.8}
        },


        State {
            name: "disappearAnimation"
            PropertyChanges { target: previewImage; visible: true }
            PropertyChanges { target: photo; x:clickX; y:clickY; width: 0; height: 0}
        },
        State {
            name: "showList"
            PropertyChanges {target: previewImage; visible: false }
            PropertyChanges { target: photo; x:clickX -50 ; y:clickY - 50;
                width: 50; height: 50}
        }
    ]

    transitions: [
        Transition {
            id: enlargeAnim
            from: "showList"
            to: "preview"
            PropertyAnimation {
                target: photo
                properties: "x, y, width, height"
                duration: 300
                easing.type: Easing.InOutQuad
                running: false
            }
        },
        Transition {
            from: "preview"
            to: "disappearAnimation"
            SequentialAnimation {
                PropertyAnimation {
                    target: photo
                    properties: "x, y, width, height"
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
                ScriptAction {
                    script: { root.state = "showList" }
                }
            }
        }
   ]

    onStateChanged: {
        appLog.debug("MainScreenView state = " + root.state);
    }

    Item {
        id: previewImage
        anchors.fill: parent
        visible: false

        Rectangle {
           anchors.fill: parent
           color: "#80000000"
        }

        function setPreviewSource(filePath) {
            photo.source = filePath;
        }


        Image {
            id:photo
            width: previewImage.width * 0.8
            height: previewImage.height * 0.8
            source: ""
            sourceSize.width: previewImage.width
        }

        function isPreviewArea(x,y) {
            if(previewImage.visible == false) return false;

            if((x>= photo.x && x <= photo.x + photo.width)
               && (y>= photo.y && y <= photo.y + photo.height)) {
                return true;
            }
            return false;
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.state == "preview" ? true : false

        onClicked: {
            //check the clicked area is inside preview
            var isInsidePreview = previewImage.isPreviewArea(mouseX, mouseY);
            if(isInsidePreview === false) root.state = "disappearAnimation"
        }

        onWheel : {
            //consuming wheel event
        }
    }

    Rectangle {
        id: loadingScrim
        color: appStyle.appColor.popupBackground
        visible: service.mediaIndexer.isOnUpdating
        width: parent.width
        height: parent.height * 0.12
        anchors.verticalCenter: parent.verticalCenter

        Text {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: appStyle.appColor.mainTextColor
            font: appStyle.engFont.mainFont42
            text: stringSheet.mediaList.onLoading + dot

            property string dot: "."
            Timer {
                repeat: true
                running: loadingScrim.visible
                interval: 1000
                onTriggered: {
                    parent.dot = parent.dot + ".";
                    if (parent.dot.length > 3)
                        parent.dot = "."
                }
            }
        }

        MouseArea {
            id: consumer
            anchors.fill: parent
            onClicked: {}
            onPressed: {}
            onReleased: {}
        }
    }
}
