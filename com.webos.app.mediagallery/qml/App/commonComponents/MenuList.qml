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

FocusScope {
    id: root

    objectName: "menuList"

    property var menuElements: []
    property bool interactive: listView.childrenRect.height > listView.height
    property alias currentIndex: listView.currentIndex

    ListModel {
        id: menuListModel
    }

    onMenuElementsChanged: {
        applyItem();
    }

    function applyItem() {
        menuListModel.clear();
        for (var i = 0 ; i < menuElements.length; i++)
            menuListModel.append({"name": menuElements[i]})
    }

    function setStartIndex(index) {
        if(listView.currentIndex != index)
            listView.currentIndex = index;
    }

    Component {
        id: listDelegate
        Item {
            id: base

            width: appStyle.relativeXBasedOnFHD(appStyle.menuItemWidth);
            height: appStyle.relativeYBasedOnFHD(appStyle.menuItemHeight + 5);

            Rectangle {
                id: text_background
                width: appStyle.relativeXBasedOnFHD(appStyle.menuItemWidth)
                height: appStyle.relativeYBasedOnFHD(appStyle.menuItemHeight);
                color: base.ListView.isCurrentItem ? appStyle.appColor.selectMenuBackground :
                    appStyle.appColor.normalMenuBackground

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                Text {
                    id: menuText
                    anchors.fill:parent
                    text: name
                    color: appStyle.appColor.mainTextColor
                    font: base.ListView.isCurrentItem? appStyle.engFont.mainFont28Bold :
                        appStyle.engFont.mainFont28
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            MouseArea {
                id: btnRoot
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    listView.currentIndex = index;
                }
                onEntered: {
                    base.forceActiveFocus();
                }
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: menuListModel
        delegate: listDelegate
        interactive: true//root.interactive
        focus: true
    }
}
