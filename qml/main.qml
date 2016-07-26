import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls.Material 2.0
import QtQuick.Dialogs 1.2

import "Components"

Item {
	id: main
	anchors.fill: parent

	QtObject {
		id: app
		property string title: "ShaderPlot"
	}

	ColumnLayout {
		anchors.fill: parent

		DefaultToolBar {
			Layout.fillWidth: true
			timeValue: "T=%1".arg(kernel.t.toFixed(2))
			onPauseTime: kernel.pauseTime()
			onResetTime: kernel.resetTime()
			onToggleBlend: kernel.blend = !kernel.blend
		}

		Plot {
			id: kernel
			Layout.fillWidth: true
			implicitHeight: width * 2./3
		}


		Controller {
			z: -1
		}

	}
}
