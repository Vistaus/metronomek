/** This file is part of Metronomek                                  *
 * Copyright (C) 2019-2021 by Tomasz Bojczuk (seelook@gmail.com)     *
 * on the terms of GNU GPLv3 license (http://www.gnu.org/licenses)   */

import QtQuick 2.12
import QtQuick.Controls 2.12

Dialog {
  id: settPage

  visible: true

  Flickable {
    width: parent.width; height: parent.height
    clip: true
    ScrollBar.vertical: ScrollBar { active: true; visible: true }
    contentWidth: parent.width; contentHeight: col.height

    Column {
      id: col
      width: parent.width
      spacing: GLOB.fontSize()

      Frame {
        width: GLOB.fontSize() * (GLOB.isAndroid() ? 21 : 30); height: GLOB.fontSize() * (GLOB.isAndroid() ? 7 : 9)
        anchors.horizontalCenter: parent.horizontalCenter

        ListModel {
          id: langModel
          ListElement { flag: "default";  lang: QT_TR_NOOP("default") }
          ListElement { flag:"pl"; lang: "polski" }
          ListElement { flag:"us"; lang: "English" }
        }

        Tumbler {
          id: langTumb
          width: parent.width; height: GLOB.fontSize() * (GLOB.isAndroid() ? 6 : 8)
          visibleItemCount: Math.min(((width / (GLOB.fontSize() * (GLOB.isAndroid() ? 5.5 : 7))) / 2) * 2 - 1, 3)
          model: langModel
          delegate: Component {
            Column {
              spacing: GLOB.fontSize() / 4
              opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
              scale: 1.7 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
              z: 1
              Image {
                source: "qrc:flags/" + flag + ".png"
                height: langTumb.height * 0.375; width: height * (sourceSize.height / sourceSize.width)
                anchors.horizontalCenter: parent.horizontalCenter
                MouseArea {
                  anchors.fill: parent
                  onClicked: langTumb.currentIndex = index
                }
              }
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: flag === "default" ? qsTr(lang) : lang
                color: activPal.text
                font { bold: langTumb.currentIndex === index; pixelSize: langTumb.height * 0.1 }
              }
            }
          }
          contentItem: PathView {
            id: pathView
            model: langTumb.model
            delegate: langTumb.delegate
            clip: true
            pathItemCount: langTumb.visibleItemCount + 1
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            dragMargin: width / 2
            path: Path {
              startX: 0
              startY: GLOB.fontSize() * 2.2
              PathLine {
                x: pathView.width
                y: GLOB.fontSize() * 2.2
              }
            }
          }
          Rectangle {
            z: -1; width: parent.height * 1.1; height: parent.height * 0.9
            x: parent.width / 2 - width / 2; y: parent.height * 0.005
            color: GLOB.alpha(activPal.highlight, 100)
            radius: width / 12
          }
        }
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter; textFormat: Text.StyledText
        text: qsTr("Select a language.<br><font color=\"red\">To take effect, this requires restarting the application!</font>")
        color: activPal.text
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: GLOB.fontSize()
        visible: outCombo.count > 1 // only when there are more devices to choose
        Label {
          id: sndLabel
          anchors.verticalCenter: parent.verticalCenter
          text: qsTr("Sound device").replace(" ", "<br>")
          textFormat: Text.StyledText
        }
        ComboBox {
          id: outCombo
          anchors.verticalCenter: parent.verticalCenter
          width: settPage.contentItem.width - sndLabel.width - GLOB.fontSize() * 2
          model: SOUND.getAudioDevicesList()
          Component.onCompleted: {
            outCombo.currentIndex = outCombo.find(SOUND.outputName())
          }
        }
      }

      Loader {
        id: andSettLoader
        sourceComponent: GLOB.isAndroid() ? andSettComp : undefined
        anchors.horizontalCenter: parent.horizontalCenter
      }

    } // Column
  } // Flickable

  standardButtons: Dialog.Cancel | Dialog.Apply

  onApplied: {
    GLOB.lang = langTumb.currentIndex === 0 ? "" : langModel.get(langTumb.currentIndex).flag
    if (outCombo.count > 1)
      SOUND.setDeviceName(outCombo.currentText)
    if (GLOB.isAndroid()) {
      GLOB.keepScreenOn(andSettLoader.item.scrOn)
      GLOB.setDisableRotation(andSettLoader.item.noRotation)
      mainWindow.visibility = andSettLoader.item.fullScr ? "FullScreen" : "AutomaticVisibility"
      GLOB.setFullScreen(andSettLoader.item.fullScr)
    }
    close()
  }

  Component.onCompleted: {
    mainWindow.dialogItem = settPage
    for (var i = 0; i < langModel.count; ++i) {
      if (langModel.get(i).flag === GLOB.lang || (i == 0 && GLOB.lang === "")) {
        //langTumb.currentIndex = i + 1 // FIXME: workaround for Qt 5.10.1
        langTumb.currentIndex = i
        break
      }
    }
  }

  onVisibleChanged: {
    if (!visible)
      destroy()
  }

  Component {
    id: andSettComp
    Column {
      property alias scrOn: screenOnChB.checked
      property alias noRotation: disRotatChB.checked
      property alias fullScr: fullScrChB.checked
      spacing: GLOB.fontSize() / 2
      CheckBox {
        id: screenOnChB
        text: qsTr("keep screen on")
        checked: GLOB.isKeepScreenOn()
      }
      CheckBox {
        id: disRotatChB
        text: qsTr("disable screen rotation")
        checked: GLOB.disableRotation()
      }
      CheckBox {
        id: fullScrChB
        text: qsTr("use full screen")
        checked: GLOB.fullScreen()
      }
    }
  }
}

