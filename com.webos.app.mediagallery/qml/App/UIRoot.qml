﻿/* @@@LICENSE
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
import "./View"
import QmlAppComponents 0.1

Item {
    id: root

    property var viewMain: _viewMain


    Image {
        id: bgImg
        source: imageDir + "bg_pattern2.png"
        width: parent.width
        height: parent.height

        y: parent.height
        x: parent.width / 4
        state: "initialized"

        states: [
            State {
                name: "initialized"
                PropertyChanges { target: bgImg; y: bgImg.parent.height; x: bgImg.parent.width / 4 }
            },
            State {
                name: "running"
                PropertyChanges { target: bgImg; y: 0; x: 0 }
            }
        ]

        transitions: [
            Transition {
                from: "initialized"
                to: "running"
                NumberAnimation { properties: "x,y"; easing.type: Easing.InOutQuad; duration: 1000}

            }
        ]

        Timer {
            interval: 50
            running: true
            onTriggered: {
                bgImg.state = "running";
            }
        }
    }

    ViewMain {
        id: _viewMain
        x: appStyle.relativeXBasedOnFHD(0)
        y: appStyle.relativeYBasedOnFHD(0)
        width: appStyle.relativeXBasedOnFHD(1920)
        height: appStyle.relativeYBasedOnFHD(720)
    }
}
