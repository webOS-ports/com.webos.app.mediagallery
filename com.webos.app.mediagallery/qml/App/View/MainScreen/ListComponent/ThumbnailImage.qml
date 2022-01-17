/* @@@LICENSE
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
import "../../../commonComponents"

Item {
    id: thumbnailImage
    property var thumbnailUrl: "thumbnailUrl"
    width: appStyle.relativeXBasedOnFHD(appStyle.gridViewSize)
    height: appStyle.relativeYBasedOnFHD(appStyle.gridViewSize)
    property string explain: ""

    Rectangle {
        anchors.fill: parent
        color: "black"
        visible: fileImage.status === Image.Ready
    }

    Image {
        id: fileImage
        anchors.fill: parent
        source: thumbnailUrl
        sourceSize.width: width
        asynchronous: true
        fillMode: Image.PreserveAspectFit
    }
    Image{
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.4
        height: parent.height * 0.4
        source: "../../../Images/empty_image.png"
        sourceSize.width: width
        fillMode: Image.PreserveAspectFit
        visible: fileImage.status !== Image.Ready
    }
    Text {
        anchors.bottom: parent.bottom
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        color: appStyle.appColor.mainTextColor
        font: appStyle.engFont.mainFont24
        text: explain
        visible: fileImage.status != Image.Ready
        elide: Text.ElideRight
    }
}
