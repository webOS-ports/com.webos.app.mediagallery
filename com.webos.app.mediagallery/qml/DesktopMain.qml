/* @@@LICENSE
*
*      Copyright (c) 2019-2022 LG Electronics, Inc.
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

import QtQuick 2.4
import Eos.Controls 0.1
import Eos.Style 0.1

FocusScope {
    id: root
    property var desktopRoot: root

    property real scaler: 0.5
    readonly property url desktopImageUrl: ""

//  AVN
//    width: 2880 * scaler
//    height: 1080 * scaler

//  RSE
    width: 2880 * scaler
    height: 1620 * scaler
    focus: true

    Rectangle {
        anchors.fill: parent
        id: desktopBg
        color: "black"
    }

    // application
    Loader {
        id: appLoader
        source: "./App/appMain.qml"
        scale: root.scaler
        transformOrigin: Item.BottomLeft
        //anchors.fill: parent
        anchors.bottom: parent.bottom
        focus: true

        onStatusChanged: {
            if (status === Loader.Ready)
                item.isDesktopMode = true;
        }
    }

    // Debug window. Will not be shipped under release build
    Loader {
        id: debugWindowLoader
        source: "./DebugWindow/DebugWindow.qml"
        focus: false
        x: 0
        y: parent.height * 0.05
        width: parent.width * 0.9
        height: parent.height * 0.9

//        property bool mainServiceReady: (mainService.status == Loader.Ready) && (debugWindowLoader.status == Loader.Ready)

//        onMainServiceReadyChanged: {
//            debugWindowLoader.item.service = Qt.binding( function() {return appLoader.item.service;} );
//        }
    }
}
