/* @@@LICENSE
 *
 * Copyright (c) <2013-2014> LG Electronics, Inc.
 *
 * Confidential computer software. Valid license from LG required for
 * possession, use or copying. Consistent with FAR 12.211 and 12.212,
 * Commercial Computer Software, Computer Software Documentation, and
 * Technical Data for Commercial Items are licensed to the U.S. Government
 * under vendor's standard commercial license.
 *
 * LICENSE@@@ */

import QtQuick 2.4

ShaderEffect {
    property real elideStart
    property real elideEnd
    property real elideLeftStart
    property real elideLeftEnd

    property real _unitsPerPixel: width > 0 ? 1 / width : 0

    property real _start: elideStart * _unitsPerPixel
    property real _end: elideEnd * _unitsPerPixel
    property real _leftStart: elideLeftStart * _unitsPerPixel
    property real _leftEnd: elideLeftEnd * _unitsPerPixel

    fragmentShader: "
        #define M_PI 3.1415926535897932384626433832795
        uniform highp float _start;
        uniform highp float _end;
        uniform highp float _leftStart;
        uniform highp float _leftEnd;

        uniform lowp sampler2D source;
        uniform highp float qt_Opacity;
        varying highp vec2 qt_TexCoord0;
        void main() {
            highp vec4 texColor = texture2D(source, qt_TexCoord0);
            if (qt_TexCoord0.s >= _end || qt_TexCoord0.s < _leftStart) {
                texColor.a = 0.0;
            }
            else if (qt_TexCoord0.s >= _start) {
                // gradient base on cosinus
//                highp float normalizedElideWidth = (M_PI / 2.0) / (_end - _start);
//                texColor.a = texColor.a * (cos(normalizedElideWidth * (qt_TexCoord0.s - _start)));

                // gradient based on sinus
//                highp float normalizedElideWidth = (M_PI / 2.0) / (_end - _start);
//                texColor.a = texColor.a * (1.0 - sin(normalizedElideWidth * (qt_TexCoord0.s - _start)));

                // linear gradient
//                highp float normalizedElideWidth = 1.0 / (_end - _start);
//                texColor.a = texColor.a * (1.0 - (normalizedElideWidth * (qt_TexCoord0.s - _start)));

                // quadratic gradient
                highp float normalizedElideWidth = 1.0 / (_end - _start);
                texColor = texColor * (1.0 - pow((normalizedElideWidth * (qt_TexCoord0.s - _start)), 2.0));
            }
            else if (qt_TexCoord0.s < _leftEnd) {
                // quadratic gradient
                highp float normalizedElideWidth = 1.0 / (_leftEnd - _leftStart);
                texColor = texColor * (1.0 - pow((normalizedElideWidth * (_leftEnd - qt_TexCoord0.s)), 2.0));
            }
            texColor = texColor * qt_Opacity;
            gl_FragColor = texColor;
        }
    "
}