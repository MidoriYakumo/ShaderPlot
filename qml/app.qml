import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0
import "Components"

ApplicationWindow {
	id: app
	visible: true
	width: 600 + 48
	height: 600 + 48 + 48
	title: qsTr("ShaderPlot")

	header: DefaultToolBar {
		timeValue: "T=%1".arg(kernel.t.toFixed(2))
		onPauseTime: kernel.pauseTime()
		onResetTime: kernel.resetTime()
		onToggleBlend: kernel.blend = !kernel.blend
		onDetachControl: {
			nvbg.enabled = !nvbg.enabled
			controller.movable = !controller.movable
			if (dummy.state == "detached")
				dummy.state = "attached"
			else
				dummy.state = "detached"
		}
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
				id: drawCol
				anchors.fill: parent

				DefaultToolBar {
					Layout.fillWidth: true
					timeValue: "T=%1".arg(kernel.t.toFixed(0))
					onResetTime: kernel.resetTime()
					onToggleBlend: kernel.blend = !kernel.blend
					z: 1
				}

				Controller {
					id: controller
				}
		}

		onClosed: dummy.focus = true
	}

	Item {
		id: dummy
		focus: true
		z: -1
		Keys.onPressed:
			if (event.key === Qt.Key_Escape ||
				event.key === Qt.Key_Back) {
				Qt.quit()
			}

		state: "attached"

		states: [
			State {
				name: "attached"
				ParentChange {
					target: controller
					parent: drawCol
				}
			},
			State {
				name: "detached"
				ParentChange {
					target: controller
					parent: kernel

					height: controller.minHeight
					width: 360
					x: /*8 + */48
					y: 8
				}
			}

		]
	}
}
