import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import "."

Rectangle {
	id: root
	Layout.fillWidth: true
	Layout.fillHeight: true

	property int minHeight: 510 + 48
	property bool movable: false

	Drag.active: dragger.drag.active

	Rectangle {
		id: handler
		width: root.width
		height: root.movable?48:0
		color: Material.primary
		clip: true

		Material.foreground: "white"

		MouseArea {
			id: dragger
			anchors.fill: parent
			enabled: root.movable
			drag.target: root
		}

		RowLayout {
			anchors.fill: handler

			Label {
				anchors.left: parent.left
				anchors.leftMargin: 8
				anchors.verticalCenter: parent.verticalCenter
				font.pixelSize: 48*.6
				text: "Options"
			}

			CheckBox {
				id: cF0
				text: "f0"
				font.pixelSize: 16
				checked: kernel.flag0
				Binding {
					target: kernel
					property: "flag0"
					value: cF0.checked
				}
			}
			CheckBox {
				id: cF1
				text: "f1"
				font.pixelSize: 16
				checked: kernel.flag1
				Binding {
					target: kernel
					property: "flag2"
					value: cF1.checked
				}
			}
			CheckBox {
				id: cF2
				text: "f2"
				font.pixelSize: 16
				checked: kernel.flag2
				Binding {
					target: kernel
					property: "flag2"
					value: cF2.checked
				}
			}
		}

	}

	Flickable {
		anchors.fill: parent
		anchors.topMargin: root.movable?48:0
		interactive: true

		contentHeight: Math.max(height, 510)
		contentWidth: Math.max(width, 360)

		ColumnLayout {
			id: dCol
			anchors.fill: parent
			anchors.margins: spacing / 2
			spacing: 16

			property alias fontSize: tExp.font.pixelSize

			RowLayout {
				Label {
					text: "0=F(x,y)="
					font.pixelSize: dCol.fontSize
				}
				TextField {
					id: tExp
					text: kernel.exp
					Layout.fillWidth: true

					onTextChanged: {
						if (kernel.mode == 0)
							kernel.exp_color = text
						else
							kernel.exp_line = text
					}
				}
			}

			ComboBox {
				id: cbMode
				Layout.fillWidth: true
				model: Source.modeList
				currentIndex: kernel.mode
				Binding {
					target: kernel
					property: "mode"
					value: cbMode.currentIndex
				}
			}

			RowLayout {
				Label {
					text: "Range x:"
					font.pixelSize: dCol.fontSize
				}

				TextField {
					id: minX
					Layout.fillWidth: true
					horizontalAlignment: TextInput.AlignHCenter
					validator: DoubleValidator {
						top: kernel.range.y
					}
					text: kernel.range.x.toPrecision(4)
					onEditingFinished: kernel.range.x = parseFloat(
										   text).toPrecision(4)
					color: acceptableInput ? Material.foreground : Material.accent
				}

				Label {
					text: "-"
					font.pixelSize: dCol.fontSize
				}

				TextField {
					id: maxX
					Layout.fillWidth: true
					horizontalAlignment: TextInput.AlignHCenter
					validator: DoubleValidator {
						bottom: kernel.range.x
					}
					text: kernel.range.y.toPrecision(4)
					onEditingFinished: kernel.range.y = parseFloat(
										   text).toPrecision(4)
					color: acceptableInput ? Material.foreground : Material.accent
				}
			}

			RowLayout {
				Label {
					text: "Range y:"
					font.pixelSize: dCol.fontSize
				}

				TextField {
					id: minY
					Layout.fillWidth: true
					horizontalAlignment: TextInput.AlignHCenter
					validator: DoubleValidator {
						top: kernel.range.w
					}
					text: kernel.range.z.toPrecision(4)
					onEditingFinished: kernel.range.z = parseFloat(
										   text).toPrecision(4)
					color: acceptableInput ? Material.foreground : Material.accent
				}

				Label {
					text: "-"
					font.pixelSize: dCol.fontSize
				}

				TextField {
					id: maxY
					Layout.fillWidth: true
					horizontalAlignment: TextInput.AlignHCenter
					validator: DoubleValidator {
						bottom: kernel.range.z
					}
					text: kernel.range.w.toPrecision(4)
					onEditingFinished: kernel.range.w = parseFloat(
										   text).toPrecision(4)
					color: acceptableInput ? Material.foreground : Material.accent
				}
			}

			RowLayout {
				Label {
					text: "dt/s:"
					font.pixelSize: dCol.fontSize
				}
				Slider {
					id: sDts
					Layout.fillWidth: true
					from: 0.1
					to: 10
					value: kernel.dts
					Binding {
						target: kernel
						property: "dts"
						value: sDts.value
					}
				}
				Label {
					id: tT
					text: (sDts.from + (sDts.to - sDts.from) * sDts.position).toFixed(
							  1)
					font.pixelSize: dCol.fontSize
				}
			}

			RowLayout {
				Label {
					text: "Linewidth:"
					font.pixelSize: dCol.fontSize
				}
				Slider {
					id: sLw
					Layout.fillWidth: true
					from: 0.1
					to: 10
					value: kernel.lw
					Binding {
						target: kernel
						property: "lw"
						value: sLw.value
					}
				}
				Label {
					id: tLw
					text: (sLw.from + (sLw.to - sLw.from) * sLw.position).toFixed(
							  1)
					font.pixelSize: dCol.fontSize
				}
			}

			RowLayout {
				Label {
					text: "Line color"
					font.pixelSize: dCol.fontSize
				}

				ToolButton {
					contentItem: Rectangle {
						id: rLineColor
						color: kernel.lc
					}
					Binding {
						target: kernel
						property: "lc"
						value: rLineColor.color
					}
					onClicked: {
						colorDialog.route = rLineColor
						colorDialog.open()
					}
				}
				Label {
					text: "Fill color"
					font.pixelSize: dCol.fontSize
				}

				ToolButton {
					contentItem: Rectangle {
						id: rFillColor
						color: kernel.ac
					}
					Binding {
						target: kernel
						property: "ac"
						value: rFillColor.color
					}
					onClicked: {
						colorDialog.route = rFillColor
						colorDialog.open()
					}
				}

				Label {
					text: "Custom code:"
				}
			}

			Rectangle {
				Layout.fillHeight: true
				Layout.fillWidth: true
				border.width: 2
				border.color: customFunc.focus ? Material.accent : Material.primary
				clip: true
				TextEdit {
					id: customFunc
					anchors.fill: parent
					anchors.margins: 8
					text: kernel.customFunc

					onEditingFinished: kernel.customFunc = text
				}
			}
		}
	}
	ColorDialog {
		id: colorDialog
		visible: false
		modality: Qt.WindowModal
		showAlphaChannel: kernel.blend

		property var route: rLineColor

		color: route.color
		onAccepted: route.color = color
	}

	property real elevation: dragger.pressed?24.:4.

	Behavior on elevation {
		NumberAnimation {
			duration: 100
		}
	}

	layer.enabled: movable
	layer.effect: DropShadow {
		id: shadow

		samples: elevation * 2
		radius: elevation
	}
}
