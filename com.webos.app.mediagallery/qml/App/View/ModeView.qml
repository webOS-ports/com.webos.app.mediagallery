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
import "../commonComponents"

/*
    ModeView --- MenuList
*/

FocusScope {
    id: root
    clip: true
    //focus: true

    signal notifyModeClicked(int index)

    function setStartPoint(modeIndex) {
        menuList.setStartIndex(modeIndex);
    }

    Rectangle {
        anchors.fill: parent
        color: appStyle.appColor.itemBackground
    }

    MenuList {
        id: menuList
        anchors.fill: parent
        menuElements: stringSheet.modeView.mode
        focus: true
        opacity: root.activeFocus ? 1.0 : 0.6

        onCurrentIndexChanged: {
            root.notifyModeClicked(currentIndex);
        }
    }
}
