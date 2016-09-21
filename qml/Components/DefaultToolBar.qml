import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0

ToolBar {
	Material.foreground: "white"
	width: parent.width

	property alias nvbg: nvbg
	property alias timeValue: bTime.text
	signal resetTime
	signal pauseTime
	signal toggleBlend
	signal detachControl

	RowLayout {
		spacing: 8
		anchors.fill: parent

		ToolButton {
			id: nvbg
			contentItem: Image {
				fillMode: Image.Pad
				horizontalAlignment: Image.AlignHCenter
				verticalAlignment: Image.AlignVCenter
				source: "../../assets/icon.png"
			}

			onClicked: {
				if (drawer.position>0)
					drawer.close()
				else
					drawer.open()
			}
		}

		Button {
			text: app.title
			flat: true
			implicitHeight: nvbg.height
			font.pixelSize: nvbg.height *.5
//			font.pointSize: 18
			onClicked: toggleBlend()
			onPressAndHold: detachControl()
		}

		Button {
			id: bTime
			flat: true
			implicitHeight: nvbg.height
			font.pixelSize: nvbg.height *.5
//			font.pointSize: 18
			onClicked: pauseTime()
			onPressAndHold: resetTime()
		}

		Item {
			Layout.fillWidth: true
		}
	}
}
