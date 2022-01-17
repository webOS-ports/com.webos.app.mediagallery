﻿/* @@@LICENSE
*
*      Copyright (c) 2021 LG Electronics, Inc.
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

AppStringSheet {
    id: root

    appTitle: rtlCode + qsTr("MediaGallery") + es
    appId: "com.webos.app.mediagallery"
    //appIdForLSService exists.
    displayId: "-1"

    property QtObject category: QtObject {
        property string image: "Image"
        property string video: "Video"
        property string audio: "Audio"
    }

    property QtObject viewerApps: QtObject {
        property string image: "com.webos.app.imageviewer"
        property string video: "com.webos.app.videoplayer"
        property string audio: "com.webos.app.avn.music"
    }

    property QtObject modeView: QtObject {
        property var mode: [
            qsTr(category.image) + es,
            qsTr(category.video) + es,
            qsTr(category.audio) + es
        ]
    }

    property QtObject mediaList: QtObject {
        property string onLoading: qsTr("Loading") + es
    }
}
