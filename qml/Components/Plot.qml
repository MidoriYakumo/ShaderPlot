import QtQuick 2.0
import Qt.labs.settings 1.0

import "."

Rectangle {
	id: root

	color: "white" // valid when blend = true

	property int mode: 0
	property string customFunc: ""
	property string exp: (mode == 0) ? exp_color : deEquation(exp_line)
	property string exp_color: "mod(t,r)/2., mod(t,r), mod(t,r)"
	property string exp_line: "(t*t-x*x-y*y)*((((((.3*x)+.8)*x-.2)*x+5.)*2.-12.)*x-3.-y/t)"
	property vector4d range: Qt.vector4d(-5, 5, -5, 5)
	property real dts: 1.
	property real lw: 1.
	property color lc: "red"
	property color ac: "lightblue"
	property bool blend: true

	property real rxTickStep: Math.pow(10., Math.round(Math.log((range.y-range.x)/4.)/Math.log(10)))
	property real ryTickStep: Math.pow(10., Math.round(Math.log((range.w-range.z)/4.)/Math.log(10)))

	Settings {
		id: settings
		property alias mode: root.mode
		property alias customFunc: root.customFunc
		property alias exp_color: root.exp_color
		property alias exp_line: root.exp_line
		property alias range: root.range
		property alias dts: root.dts
		property alias lw: root.lw
		property alias lc: root.lc
		property alias ac: root.ac
		property alias blend: root.blend
	}

	signal resetTime
	signal pauseTime
	property real t: 0.

	function deEquation(s) {
		var i = s.indexOf("=")
		while (i > 0) {
			if (s[i + 1] !== '=') {
				s = s.substring(0, i) + '-' + s.substring(i + 1)
				i += 1
			} else
				i += 2
			i = s.indexOf("=", i)
		}
		//		console.log('Final sression:%1'.arg(s))
		return s
	}

	function mix(a, b, u) {
		return a * (1. - u) + b * u
	}

	ShaderEffect {
		id: plot
		anchors.fill: parent
		antialiasing: true
		smooth: true
		blending: false

		opacity: root.blend ? .99 : 1.

		property alias t: root.t
		property alias range: root.range
		property alias lw: root.lw
		property alias lc: root.lc
		property alias ac: root.ac

		property real _width: width
		property real _hegith: height

		property bool flag0: true
		property bool flag1: true
		property bool flag2: true

		fragmentShader: Source.get(mode).arg(root.exp).arg(root.customFunc)

		Behavior on t {
			id: tBehavior
			enabled: true
			NumberAnimation {
				duration: tTimer.interval
			}
		}
	}

	onRangeChanged: tick.requestPaint()

	Canvas {
		id: tick
		anchors.fill: plot
		property real padding: 8
		onPaint: {
			var ctx = tick.getContext("2d")
			ctx.reset()

			var w = tick.width
			var h = tick.height

			var margin = tick.padding
			ctx.strokeStyle = "gray"
			ctx.fillStyle = "gray"
			//ctx.fillStyle = root.lc
			ctx.beginPath()
			ctx.moveTo(margin, margin)
			ctx.lineTo(margin, h - margin)
			ctx.moveTo(margin, h - margin)
			ctx.lineTo(w - margin, h - margin)

			var t
			t = Math.ceil(range.x/rxTickStep)*rxTickStep
			ctx.font = "20px sans serif";
			while (t<range.y) {
				ctx.moveTo((t-range.x)*w/(range.y-range.x), h-margin)
				ctx.lineTo((t-range.x)*w/(range.y-range.x), h-2*margin)
				ctx.fillText(t.toPrecision(4), (t-range.x)*w/(range.y-range.x), h-2*margin);
				t += rxTickStep
			}
			t = Math.ceil(range.z/ryTickStep)*ryTickStep
			while (t<range.w) {
				ctx.moveTo(margin, h-(t-range.z)*h/(range.w-range.z))
				ctx.lineTo(margin*2, h-(t-range.z)*h/(range.w-range.z))
				ctx.fillText(t.toPrecision(4), margin + 2 , h-(t-range.z)*h/(range.w-range.z)-5);
				t += ryTickStep
			}

			ctx.stroke()
		}
	}

	MouseArea {
		anchors.fill: plot

		property point sp

		onPressed: sp = Qt.point(mouse.x, mouse.y)
		onPositionChanged: {
			var dx = (mouse.x - sp.x) * -(root.range.y - root.range.x) / plot.width
			var dy = (mouse.y - sp.y) * (root.range.w - root.range.z) / plot.height
			root.range.x += dx
			root.range.y += dx
			root.range.z += dy
			root.range.w += dy
			sp = Qt.point(mouse.x, mouse.y)
		}

		onWheel: {
			var r = 1. / 240
			var d = 1 + r * -wheel.angleDelta.y
			range.x = mix(mix(root.range.x, root.range.y, wheel.x / plot.width), root.range.x,  d)
			range.y = mix(mix(root.range.x, root.range.y, wheel.x / plot.width), root.range.y,  d)
			range.z = mix(mix(root.range.z, root.range.w, 1.-wheel.y / plot.height), root.range.z, d)
			range.w = mix(mix(root.range.z, root.range.w, 1.-wheel.y / plot.height), root.range.w, d)
		}
	}

	Timer {
		id: tTimer
		interval: 200
		repeat: true
		running: true
		triggeredOnStart: true

		onTriggered: t += dts * .2
	}

	onPauseTime: tTimer.running = !tTimer.running

	onResetTime: {
		tBehavior.enabled = false
		tTimer.stop()
		t = 0
		tBehavior.enabled = true
		tTimer.start()
	}

	Component.onCompleted: resetTime()

	//	onRangeChanged: console.log("range=%1".arg(range))
}
