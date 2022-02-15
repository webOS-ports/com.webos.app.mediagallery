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

import QtQuick 2.12
import QmlAppComponents 0.1
import "../../../commonComponents"

FocusScope {
    id: root

    Component.onCompleted: {
        updateListModel();
    }

    property var clickAction: function(index) {}

    property var componentLayout: "" // qml file name: ex) ThumbnailImage.qml
    property var componentParam: ({}) //{ [asynchronous param name in layout]: [key name in data list], ... }
    property var componentSize: ({})

    property var isScrolling: false

    property var gridViewWidth: 200 - 10
    property var gridViewHeight: 200 - 10

    property var delayLoadingTime: 300

    property var spacingH: appStyle.relativeXBasedOnFHD(5) + 5
    property var spacingV: appStyle.relativeYBasedOnFHD(5) + 5

    Rectangle {
        anchors.fill: bgGridView
        color: "white"
        opacity: 0.3
        visible: thumbnailGridView.activeFocus
    }

    GridView {
        id: bgGridView
        enabled: false
        anchors.fill: thumbnailGridView
        model: gridViewListModel.count < 20 ? dummyModel : thumbnailGridView.model
        focus: false

        Component.onCompleted: {
            var i;
            for (i = 0 ; i < 20 ; i++) {
                dummyModel.append({"name":"dummy"});
            }
        }

        ListModel {
            id: dummyModel
        }

        cellWidth: thumbnailGridView.cellWidth
        cellHeight: thumbnailGridView.cellHeight
        delegate: bgDelegate
        //focus: false

        contentY: thumbnailGridView.contentY
        contentX: thumbnailGridView.contentX

        Component {
            id: bgDelegate
            Item
            {
                id: base
                width: bgGridView.cellWidth
                height: bgGridView.cellHeight
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: spacingV / 2
                    anchors.bottomMargin: spacingV /2
                    anchors.leftMargin: spacingH /2
                    anchors.rightMargin: spacingH / 2
                    color: appStyle.appColor.itemBackground
                }

            }
        }
    }

    Component {
        id: listDelegate

        Item {
            id: base
            width: thumbnailGridView.cellWidth
            height: thumbnailGridView.cellHeight

            Keys.onPressed: {
                if (mainScreenView.getPreviewVisible()) {

                    switch(event.key) {
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                        mainScreenView.previewMouseArea.previewClicked();
                        break;
                    default:
                        mainScreenView.state = "disappearAnimation"
                        break;
                    }
                    event.accepted = true;
                } else {
                    switch(event.key) {
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                        var absXY = mouseAreaInGridDelegate.absolutePosition(thumbnailGridView.currentIndex, 0,0);
                        clickAction(thumbnailGridView.currentIndex,absXY.X,absXY.Y);
                        event.accepted = true;
                        break;
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "white"
                opacity: 0.5
                visible: base.activeFocus
            }
            Component.onCompleted: {
//                appLog.debug("onCompleted :: " + index);
            }

            Component.onDestruction:  {
//                appLog.debug("onDestruction :: " + index);
            }

            function getParamForLayout(setSizeParams, setOtherParams) {
                var param = ({});

                if(setSizeParams) {
                    param["width"] = componentSize.width == undefined
                            ? (gridViewWidth - spacingH)
                            : (componentSize.width - spacingH)

                    param["height"] = componentSize.height == undefined
                            ? (gridViewHeight - spacingV)
                            : (componentSize.height - spacingV)
                }

                if(setOtherParams) {
                    Object.keys(componentParam).forEach(function(keyName){
                        param[keyName] = (gridViewListModel.get(index))[componentParam[keyName]]
                    })
                }

                return param;
            }

            Item {
                id: contentBase
                anchors.fill: parent

                anchors.topMargin: spacingV / 2
                anchors.bottomMargin: spacingV /2
                anchors.leftMargin: spacingH /2
                anchors.rightMargin: spacingH / 2
                Component.onCompleted: {
                    if (isScrolling == false) {
                        // ex)loader.setSource("ThumbnailImage.qml",{"thumbnailUrl":thumbnail});
                        loader.setSource(componentLayout, getParamForLayout(true, true));
                    }
                    else {
                        loader.setSource(componentLayout, getParamForLayout(true, false));
                    }
                }

                property bool thumbnailLoaded: false

                Connections {
                    target: root
                    onIsScrollingChanged: {
                        if(isScrolling == false && contentBase.thumbnailLoaded == false) {
                            appLog.debug("Scrolling stopped / "  + index + " call thumbnail");
                            loader.setSource(componentLayout, base.getParamForLayout(true, true));
                            contentBase.thumbnailLoaded = true;
                        }
                    }
                }

                Loader {
                    id: loader
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    asynchronous: true
                }
            }
            MouseArea {
                id: mouseAreaInGridDelegate
                anchors.fill:parent
                onClicked: {
                    if(isScrolling) return;
                    thumbnailGridView.currentIndex = index;
                    var absXY = absolutePosition(index, 0,0);

                    clickAction(index,absXY.X,absXY.Y);
                }

                function absolutePosition(index, x, y) {
                    var rowIndex = parseInt(index / thumbnailGridView.itemNumInRow);
                    var colIndex = parseInt(index % thumbnailGridView.itemNumInRow)

                    return {X: thumbnailGridView.cellWidth * colIndex + x,
                            Y:  thumbnailGridView.cellHeight * rowIndex + y - thumbnailGridView.contentY}
                }

            }
        }
    }

    ListModel {
        id: gridViewListModel
    }

    function updateListModel(list){
        appLog.debug("DelayRequestListComponent:: updateListModel :: " + list.length);
        initGridView();

        gridViewListModel.clear();
        for (var i = 0 ; i < list.length; i++) {
            gridViewListModel.append(list[i]);
        }
    }

    function initGridView() {
        loadImageTimer.stop();
        isScrolling = false;
        thumbnailGridView.contentY = 0;
    }

    Timer {
        id: loadImageTimer
        interval: root.delayLoadingTime
        repeat: true
        onTriggered: {
            appLog.debug("loadTimer triggered");
            if(Math.abs(thumbnailGridView.verticalVelocity) < 20) {
                repeat = false;
            } else {
                repeat = true;
            }
        }

        onRunningChanged: {
            if(running) isScrolling = true
            else isScrolling = false;
        }
    }

    GridView {
        id: thumbnailGridView
        anchors.fill: parent
        model: gridViewListModel

        cellWidth: root.gridViewWidth
        cellHeight: root.gridViewHeight
        delegate: listDelegate
        focus: true

        property int itemNumInRow: thumbnailGridView.width / thumbnailGridView.cellWidth
        property int itemNumInCol: thumbnailGridView.height / thumbnailGridView.cellHeight

        onVerticalVelocityChanged: {
            if(!isScrolling) {
                loadImageTimer.restart();
                isScrolling = true;
            }
        }
    }


    Rectangle {
        id: empty_notice_text
        anchors.fill: parent
        color: appStyle.appColor.emptyBackground
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        visible: !service.mediaIndexer.isOnUpdating
                    && gridViewListModel.count == 0
        opacity: 0.95

        Text {
            id: notice_1
            anchors.top: parent.top
            width: parent.width
            height: parent.height * 0.5
            font: appStyle.engFont.getFont(42,700)
            color: appStyle.appColor.mainTextColor
            text: "No " + currentMode + " Files"
            verticalAlignment: Text.AlignBottom
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        Text {
            anchors.top: notice_1.bottom
            anchors.topMargin: appStyle.relativeYBasedOnFHD(5)
            width: parent.width
            height: parent.height * 0.5
            font: appStyle.engFont.mainFont32
            color: appStyle.appColor.mainTextColor
            text: "Please insert " + currentMode + " files on the USB or connected device"
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 1.2
            wrapMode: Text.WordWrap
        }

    }
}
