import QtQuick 2.7
import Qt.labs.settings 1.0
import QtQuick.Window 2.2

import "."

Rectangle {
	id: root

	color: "white" // valid when blend = true

	property int mode: 0
	property string customFunc: "
FP float persp0(float x,float y){return abs(mod(x,y/10.-1.)*mod(y,1.))<.3?0.:1.;}
FP float persp1(float x,float y){return mod(x-2.*c,5.-y*s)*mod((y+t)*s,(5.-y*s));}
FP float morph0(float x, float y){return y/tan(x)-sin(x+t);}
FP float norm(float x, float y){
FP float expt1 = exp(t)-1.;
return pow(9.,expt1)-pow(x,expt1)-pow(y,expt1);
}
FP float wave0(float x, float y){return y/x-sin(x+t);}
FP float wave1(float x, float y){return sin(x*x+y*y+t);}
FP float star0(float x, float y){return sin(t*x*y);}
FP float div0(float x, float y){return y*y-sin(x*x-t);}
FP float v8wave(float x, float y){return lxy-sin(x*x+y*y-t);}
FP float v8body0(float x, float y){return distance(xy2,vec2(cos(t),sin(t-4.)));}
FP float v8body1(float x, float y){return distance(xy2,vec2(cos(t-2.),sin(t-6.)));}
FP float v8body2(float x, float y){return distance(xy2,vec2(cos(t-1.),sin(t-8.)));}
FP float v8body(float x, float y){return v8body0(x,y)*v8body1(x,y)*v8body2(x,y);}
FP float tension(float x, float y){return cross(vec3(rt,t),vec3(xy2,5.)).y*lxy-5.;}
FP float roundtangle(float x, float y){return x*(x+3.5)*(x-3.5)*y*(y+2.5)*(y-1.5)-s*35.;}

FP float displacement(FP vec3 p)
{
p.xz *= rot2;
p.xy *= rot2;
FP vec3 q = 1.75 * p;
return length(p + vec3(s)) * log(length(p) + 1.0) +
sin(q.x + sin(q.z + sin(q.y))) * 0.25 - 1.0;
}

vec3 plasma(FP float x, FP float y){
FP vec3 color;
FP float d = 2.5;
FP vec3 pos = normalize(vec3(xy2, -1.0));
for (int i = 0; i < 8; ++i) {
	FP vec3 p = vec3(0.0, 0.0, 5.0) + pos * d;
	FP float positionFactor = displacement(p);
	d += min(positionFactor, 1.0);
	FP float clampFactor =  clamp((positionFactor- displacement(p + 0.1)) * 0.5, -0.1, 1.0);
	FP vec3 l = vec3(0.2 * s, 0.35, 0.4) + vec3(5.0, 2.5, 3.25) * clampFactor;
	color = (color + (1.0 - smoothstep(0.0, 2.5, positionFactor)) * 0.7) * l;
}
return vec3(s+x, c+y, lxy)*.5 + color;
}
	"
	property string exp: (mode == 0) ? exp_color : deEquation(exp_line)
	property string exp_color: "plasma(x/7.,y/7.)"
	property string exp_line: "div0(x,y)*v8wave(x,y)"
	property vector4d range: Qt.vector4d(-5, 5, -5, 5)
	property real dts: 1.
	property real lw: 2.
	property color lc: "#ff3a86"
	property color ac: "#6055a7ff"
	property bool blend: true

	property bool flag0: true
	property bool flag1: true
	property bool flag2: false

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

		property alias flag0: root.flag0
		property alias flag1: root.flag1
		property alias flag2: root.flag2

	}

	signal resetTime
	signal pauseTime
	property real t: 0.

	function deEquation(s) {
		var foundEqual = false
		var i = s.indexOf("=")
		while (i > 0) {
			if (s[i + 1] !== '=') {
				s = s.substring(0, i) + ')-(' + s.substring(i + 1)
				i += 4
				foundEqual = true
			} else
				i += 2
			i = s.indexOf("=", i)
		}
		if (foundEqual)
			s = '(' + s + ')'
		//		console.log('Final sression:%1'.arg(s))"
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

		property alias flag0: root.flag0
		property alias flag1: root.flag1
		property alias flag2: root.flag2

		fragmentShader: Source.get(mode).arg(root.exp).arg(root.customFunc)
			.arg((OpenGLInfo.majorVersion>=3 && OpenGLInfo.renderableType===2)?"precision FP float;":"")

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
		anchors.centerIn: plot
		width: plot.width/scale
		height: plot.height/scale
		scale: 80/25.4/Screen.pixelDensity
		property real padding: 14
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
			ctx.font = "28px sans serif";
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
