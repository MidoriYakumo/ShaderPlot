import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0
import QtQuick.Dialogs 1.2

import "Components"

ApplicationWindow {
	id: app
	visible: true
	width: 600
	height: 600 + 48
	title: qsTr("ShaderPlot")

	header: DefaultToolBar {
		timeValue: "T=%1".arg(kernel.t.toFixed(2))
		onResetTime: kernel.resetTime()
		onToggleBlend: kernel.blend = !kernel.blend
	}

	Plot {
		id: kernel
		anchors.fill: parent
	}

	Drawer {
		id: drawer
		height: app.height
		width: Math.min(app.height, app.width) //* 2. / 3
		clip: true

			ColumnLayout {
				anchors.fill: parent

				DefaultToolBar {
					Layout.fillWidth: true
					timeValue: "T=%1".arg(kernel.t.toFixed(0))
					onResetTime: kernel.resetTime()
					onToggleBlend: kernel.blend = !kernel.blend
					z: 1
				}

				Item {
					Layout.fillWidth: true
					Layout.fillHeight: true

//					Flickable {
//						anchors.fill: parent
//						interactive: true
//						flickableDirection: Flickable.VerticalFlick

					ColumnLayout {
						id: dCol
						anchors.fill: parent
						anchors.margins: spacing / 2
						spacing: 16

						property alias fontSize: tExp.font.pixelSize

						RowLayout {
							Label {
								text: "Eval(x,y)(=0):"
								font.pixelSize: dCol.fontSize
							}
							TextField {
								id: tExp
								text: kernel.exp
								Layout.fillWidth: true

								onTextChanged: if (kernel.mode == 0)
												   kernel.exp_color = text
											   else
												   kernel.exp_line = text
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
							TextEdit {
								id: customFunc
								anchors.fill: parent
								anchors.margins: 8
								text: kernel.customFunc

								onEditingFinished: kernel.customFunc = text
							}
						}
						//					Item {
						//						Layout.fillHeight: true
						//					}
					}
//				}
			}
		}

		onClosed: keyHandler.focus = true
	}

	ColorDialog {
		id: colorDialog
		visible: false
		modality: Qt.WindowModal
		showAlphaChannel: true

		property var route: rLineColor

		color: route.color
		onAccepted: route.color = color
	}

	Item {
		id: keyHandler
		focus: true
		z: -1
		Keys.onPressed:
			if (event.key === Qt.Key_Escape ||
				event.key === Qt.Key_Back) {
				Qt.quit()
			}
	}
}
