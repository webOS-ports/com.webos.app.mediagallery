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
import "./View"
import QmlAppComponents 0.1

FocusScope {
    id: root

    property var viewMain: _viewMain
    focus: true
    objectName: "uiRoot"

    Rectangle {
        anchors.fill: parent
        color: appStyle.appColor.mainBackground
    }

//    Image {
//        id: bgImg
//        source: appStyle.background
//        width: parent.width
//        height: parent.height

//        y: parent.height
//        x: parent.width / 4
//        state: "initialized"

//        states: [
//            State {
//                name: "initialized"
//                PropertyChanges { target: bgImg; y: bgImg.parent.height; x: bgImg.parent.width / 4 }
//            },
//            State {
//                name: "running"
//                PropertyChanges { target: bgImg; y: 0; x: 0 }
//            }
//        ]

//        transitions: [
//            Transition {
//                from: "initialized"
//                to: "running"
//                NumberAnimation { properties: "x,y"; easing.type: Easing.InOutQuad; duration: 1000}

//            }
//        ]

//        Timer {
//            interval: 50
//            running: true
//            onTriggered: {
//                bgImg.state = "running";
//            }
//        }
//    }

    ViewMain {
        id: _viewMain

        anchors.fill: parent
        anchors.topMargin: appStyle.relativeYBasedOnFHD(30)
        anchors.bottomMargin: appStyle.relativeYBasedOnFHD(10)
        anchors.leftMargin: appStyle.relativeXBasedOnFHD(10)
        anchors.rightMargin: appStyle.relativeXBasedOnFHD(10)
        focus: true
    }
}
