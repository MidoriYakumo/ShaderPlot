import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0
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
			if (dummy.state == "detached")
				dummy.state = "attached"
			else
				dummy.state = "detached"
			//nvbg.enabled = !controller.movable
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
				PropertyChanges {
					target: controller
					movable: false
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
				PropertyChanges {
					target: controller
					movable: true
				}
			}

		]

		Settings {
			id: settings
			property alias app_x: app.x
			property alias app_y: app.y
			property alias app_width: app.width
			property alias app_height: app.height
			property alias app_state: dummy.state
		}

	}
}
