/* @@@LICENSE
*
*      Copyright (c) 2020-2022 LG Electronics, Inc.
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

Rectangle {
    id: root
    color: "transparent"

    property var service: findObjectByObjectName(desktopRoot, "serviceRoot")

    state: "closed"
    states: [
        State {
            name: "opened"
            PropertyChanges { target: root; x: 0 }
        },
        State {
            name: "closed"
            PropertyChanges { target: root; x: -1 * root.width }
        }
    ]

    function toggle() {
        if (state == "opened") {
            state = "closed";
        } else {
            state = "opened";
        }
    }

    transitions: [
        Transition {
            from: "opened"
            to: "closed"
            reversible: true
            NumberAnimation { properties: "x"; easing.type: Easing.InOutQuad; duration: 300 }
        }
    ]

    // open button
    Button {
        id: dbgWindowToggleButton
        text: root.state === "opened" ? "<" : ">"
        width : 50
        height: 50
        anchors.left: parent.right
        style: DebugButtonStyle {}
        onClicked: {
            root.toggle();
        }
    }

    // debug buttons

    Flow {
        spacing: 10
        anchors.fill: parent
        Button {
            id: sampleDbgButton
            text: "state : musicplay"
            width : 150
            height: 50
            style: DebugButtonStyle {}

            onClicked: {
                var obj = findObjectByObjectName(desktopRoot,"viewMain");
                obj.state = "NowPlaying"
            }
        }

        Button {
            id: sampleDbgButton2
            text: "state : find!"
            width : 150
            height: 50
            style: DebugButtonStyle {}

            onClicked: {
                var obj = findObjectByFocus(desktopRoot);
            }
        }
    }

    function findObjectByFocus(root) {
        for (var i = 0 ; i < root.children.length; i++ ) {
            if (root.children[i].activeFocus === true) {
                console.warn("...",root.children[i] + "_" + root.children[i].objectName,"[",root.children[i].focus,root.children[i].activeFocus,"]");
                console.info("Found Correct Object",root.children[i], root.children[i].objectName);
                return root.children[i];
            }
            else {
                var branch = findObjectByFocus(root.children[i]);
                console.warn("...",root.children[i] + "_" + root.children[i].objectName,"[",root.children[i].focus,root.children[i].activeFocus,"]");
                if (branch !== 0)
                    return branch;
            }
        }
        return 0;
    }


    function findObjectByObjectName(root,targetName) {
        for (var i = 0 ; i < root.children.length; i++ ) {
            if (root.children[i].objectName === "ignore")
                continue;
            if (root.children[i].objectName === targetName) {
                console.info("Found Correct Object",root.children[i],targetName);
                return root.children[i];
            }
            else {
                var branch = findObjectByObjectName(root.children[i],targetName);
                if (branch !== 0)
                    return branch;
            }
        }
        return 0;
    }
}
