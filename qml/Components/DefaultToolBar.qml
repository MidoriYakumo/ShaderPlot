import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0

ToolBar {
	Material.foreground: "white"
	width: parent.width

	property alias timeValue: bTime.text
	signal resetTime
	signal toggleBlend

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
			implicitHeight: nvbg.height
			flat: true
			font.pixelSize: nvbg.height *.5
//			font.pointSize: 18
			onClicked: toggleBlend()
		}

		Button {
			id: bTime
			implicitHeight: nvbg.height
			flat: true
			font.pixelSize: nvbg.height *.5
//			font.pointSize: 18
			onClicked: resetTime()
		}

		Item {
			Layout.fillWidth: true
		}
	}
}
