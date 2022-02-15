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
import QtGraphicalEffects 1.0

FocusScope {
    id: root

    property var clickAcion: function(index) {}
    property int elementWidth: 200
    property int elementHeight: 200
    property var spacing: 30
    property var contentSpacing: 7

    function updateListModel(list) {
        appLog.debug("HorizentalListComponent :: start update List");
        listModel.clear();
        for(var i = 0; i < list.length; i++) {
            var listValue = list[i];
            listModel.append({itemToShow: listValue});
        }
        appLog.debug("HorizentalListComponent :: end update List");
    }

    function setStartIndex(index) {
        horizontalListView.currentIndex = index;
        appLog.debug("HorizentalListComponent :: set start index = " + index);
    }

    property bool isHighlightLast: listModel.count > 0 ?
            horizontalListView.isRightEnd : true
    property bool isHighlightFirst: listModel.count > 0 ?
            horizontalListView.isLeftEnd : true

    readonly property string forward: "foward";
    readonly property string backward: "backward";

    property var moveIndexDirection: forward;

    Timer {
        id: fastfowardTimer
        interval: 100; repeat: true; triggeredOnStart: true
        onTriggered: {
            var prevIndex = horizontalListView.currentIndex;
            if(moveIndexDirection == forward) moveIndexFoward();
            else moveIndexBackward();
            if(prevIndex === horizontalListView.currentIndex) {
                running = false;
            }
        }
        onRunningChanged: {
            if(running == false) {
                clickAcion(horizontalListView.currentIndex);
            }
        }
    }

    function moveFast(direction) {
        moveIndexDirection = direction;
        fastfowardTimer.start();
    }

    function moveStop() {
        if(fastfowardTimer.running == true)
            fastfowardTimer.stop();
    }

    function moveIndex(direction) {
        if(direction === forward) {
            moveIndexFoward();
        } else {
            moveIndexBackward();
        }

        clickAcion(horizontalListView.currentIndex);
    }

    function moveIndexFoward() {
        if(horizontalListView.currentIndex < listModel.count -1) {
            horizontalListView.currentIndex += 1;
        }
    }

    function moveIndexBackward() {
        if(horizontalListView.currentIndex > 0){
            horizontalListView.currentIndex -= 1;
        }
    }

    function movePage(direction){
        var change = horizontalListView.width * (direction === forward ? -1 : 1);

        if (horizontalListView.contentX - change < 0)
            horizontalListView.contentX = 0;
        else if (horizontalListView.contentX - change > horizontalListView.contentWidth - horizontalListView.width)
            horizontalListView.contentX = horizontalListView.contentWidth - horizontalListView.width;
        else
            horizontalListView.contentX -= horizontalListView.width * (direction === forward ? -1 : 1);
    }

    Rectangle {
        anchors.fill:horizontalListView
        color:"white"
        opacity: 0.3
        radius: height / 3
        visible: horizontalListView.activeFocus
    }

    ListView {
        id: bgListView
        enabled: false
        anchors.fill: horizontalListView
        anchors.topMargin: horizontalListView.topMargin
        spacing: appStyle.relativeXBasedOnFHD(root.spacing)
        model: dummyModel
        clip: true
        Component.onCompleted: {
            var i;
            for (i = 0 ; i < 7 ; i++) {
                dummyModel.append({"name":"dummy"});
            }
        }

        ListModel {
            id: dummyModel
        }

        orientation: horizontalListView.orientation

        delegate: bgDelegate

        contentY: horizontalListView.contentY
        contentX: horizontalListView.contentX

        Component {
            id: bgDelegate
            Item {
                id: emptyBase
                width: root.elementWidth
                height: root.elementHeight

                Item {
                    id: emptyContentBase
                    width: emptyBase.width
                    height: circleBG.height + placeholderText.height
                    anchors.horizontalCenter: emptyBase.horizontalCenter
                    anchors.verticalCenter: emptyBase.verticalCenter
                    property var spacing: appStyle.relativeYBasedOnFHD(root.contentSpacing)
                    Rectangle{
                        id: circleBG
                        anchors.top: emptyContentBase.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: height
                        height: emptyBase.height * 0.7
                        radius: height * 0.5
                        color: appStyle.appColor.placeholderBackground
                    }
                    Text {
                        id: placeholderText
                        width: parent.width
                        height: contentHeight
                        anchors.top: circleBG.bottom
                        anchors.topMargin: emptyContentBase.spacing
                        property var fontSize: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "No data"
                        font: appStyle.engFont.getFont(fontSize,700)
                        color: "transparent"
                    }
                }
            }
        }
    }


    Component {
        id: listDelegate

        Item {
            id: base
            width: root.elementWidth
            height: root.elementHeight
            property var imageList: []

            Item {
                id: contentBase
                width: base.width
                height: previewBackground.height + title.height
                anchors.horizontalCenter: base.horizontalCenter
                anchors.verticalCenter: base.verticalCenter
                property var spacing: appStyle.relativeYBasedOnFHD(root.contentSpacing)
                Item {
                    id: previewBackground
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: height
                    height: base.height * 0.7

                    Rectangle {
                        id: folderThumbnailBG
                        width: previewBackground.width
                        height: previewBackground.height
                        radius: width * 0.5
                        color: base.ListView.isCurrentItem
                               ? appStyle.appColor.categoryFocusBackground
                               : appStyle.appColor.categoryNormalBackground
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    Rectangle {
                        id: folderThumbnail
                        color: "transparent"
                        width: parent.width * 0.6
                        height: parent.height * 0.6
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        property real spacingH: 5
                        property real spacingV: 5
                        property int itemWidth: folderThumbnail.width / 2 - (folderThumbnail.spacingH / 2)
                        property int itemHeight: folderThumbnail.width / 2 - (folderThumbnail.spacingV / 2)

                        RoundSquareThumbnail {
                            id: image1
                            anchors.top: folderThumbnail.top
                            anchors.left: folderThumbnail.left
                            width: parent.itemWidth
                            height: parent.itemHeight
                            src: imageList[0]

                        }
                        RoundSquareThumbnail {
                            id: image2
                            anchors.top: folderThumbnail.top
                            anchors.right: folderThumbnail.right
                            width: parent.itemWidth
                            height: parent.itemHeight
                            src: imageList[1]
                        }
                        RoundSquareThumbnail {
                            id: image3
                            anchors.bottom: folderThumbnail.bottom
                            anchors.left: folderThumbnail.left
                            width: parent.itemWidth
                            height: parent.itemHeight
                            src: imageList[2]
                        }
                        RoundSquareThumbnail {
                            id: image4
                            anchors.bottom: folderThumbnail.bottom
                            anchors.right: folderThumbnail.right
                            width: parent.itemWidth
                            height: parent.itemHeight
                            src: imageList[3]
                        }

                        Component.onCompleted: {
                            imageList = service.mediaIndexer.getFolderThumbnail(itemToShow)

                        }
                    }

                    Text {
                        id: title
                        width: parent.width
                        height: contentHeight
                        anchors.top: previewBackground.bottom
                        anchors.topMargin: contentBase.spacing
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: itemToShow
                        font: appStyle.engFont.getFont(20,700)
                        color: appStyle.appColor.mainTextColor
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                    }
                    Rectangle{
                        id: selected
                        anchors.horizontalCenter: previewBackground.horizontalCenter
                        anchors.verticalCenter: previewBackground.verticalCenter
                        width: previewBackground.width + appStyle.relativeXBasedOnFHD(15)
                        height: width
                        radius: width * 0.5
                        border.color: appStyle.appColor.selectLineColor
                        border.width: 4
                        color: "transparent"
                        visible: base.ListView.isCurrentItem
                        opacity: base.ListView.isCurrentItem ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }
                }
                MouseArea {
                    anchors.fill:parent
                    onClicked: {
                        appLog.debug("FolderList clicked : " + index);
                        horizontalListView.currentIndex = index;
                        clickAcion(index);
                    }
                }
            }
        }
    }

    ListModel {
        id: listModel
    }

    ListView {
        id: horizontalListView
        anchors.fill: parent
        anchors.topMargin: parent.height * 0.05
        anchors.leftMargin: appStyle.relativeXBasedOnFHD(15)
        anchors.rightMargin: appStyle.relativeXBasedOnFHD(15)
        focus: true

        Keys.onReturnPressed: {
            clickAcion(horizontalListView.currentIndex);
        }
        Keys.onEnterPressed: {
            clickAcion(horizontalListView.currentIndex);
        }

        orientation: ListView.Horizontal
        spacing: appStyle.relativeXBasedOnFHD(root.spacing)

        property bool isLeftEnd: contentX < 5
        property bool isRightEnd: contentX > ((contentWidth - horizontalListView.width)  - 5)

        delegate: listDelegate
        model: listModel

        Behavior on contentX {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 300
        snapMode: ListView.SnapOneItem

        clip: true

        property var numItemInRow: parseInt((horizontalListView.width - elementWidth) / (elementWidth + spacing)) + 1
    }
}
