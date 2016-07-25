import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Window 2.0
import QtCharts 2.1

Window {
	visible: true
	height: 600 + 40
	width: 600 + 10

	ChartView {
		id: chart
		anchors.fill: parent
		smooth: true
		antialiasing: true

		ValueAxis {
			id: xAixs
			min: -7
			max: 7
		}

		ValueAxis {
			id: yAixs
			min: -7
			max: 7
		}

		LineSeries {
			id: target
			name: "target"
			axisX: xAixs
			axisY: yAixs
			useOpenGL: !chart.smooth
		}

		LineSeries {
			id: op
			axisX: xAixs
			axisY: yAixs
			useOpenGL: !chart.smooth
			onPointAdded: {
				opDot.append(at(index).x, at(index).y)
			}
		}

		ScatterSeries {
			id: opDot
			name: "op"
			axisX: xAixs
			axisY: yAixs
		}

		LineSeries {
			id: rCoord
			axisX: xAixs
			axisY: yAixs
			useOpenGL: !chart.smooth
		}


		Component.onCompleted: {
			var y
			for (var x=-5;x<=5;x+=.1) {
				y = evaluate(x,0)
//				y = Math.sqrt(16-x*(x-1))
				target.append(x, y)
			}

			op.append(p0.x, p0.y)
			op.append(p1.x, p1.y)
			op.append(p2.x, p2.y)
		}
	}

	function evaluate(x, y) {
//		return (x*(x-.2) / 2.5 - 5) - y
//		return x*(x-1)+y*y-16
//		return Math.log(Math.abs(Math.tan(x/2))+.1)/2-y-2.
//		return Math.atan(Math.sin(x+2)*10-2)-y
//		return Math.sin(x)%.5-y-2
//		return (((((.3*x)+.8)*x-.2)*x+5)*2-12)*x-3-y
//		return Math.floor(x)-y-2.
//		return Math.exp(1./(Math.abs(x+.1)+.2))-y
		return (-.9+x)/(.1+Math.abs(1.-x))-1.-y
	}

	property real	c: 1.732*1e-3
	property point pp: Qt.point(0,0)
	property point p0: Qt.point(0,c*2./3)
	property point p1: Qt.point(-c/2,-c/3)
	property point p2: Qt.point(c/2,-c/3)
	property point lastp: pp

	property int counter: 0
	property bool auto: false

	onCounterChanged: if (auto) step.onClicked()

	Button {
		id: step
		text: "step" + counter

		ToolTip.timeout: 1000
		onClicked: {
			console.log('===============')
			var v0, v1, v2, A0, A1, z
			var p = Qt.point(0.21692, 1.4053)
			console.log("eval(%1)=%2==0 !!".arg(p).arg(evaluate(p.x, p.y)))

			v0 = evaluate(p0.x, p0.y)
			v1 = evaluate(p1.x, p1.y)
			v2 = evaluate(p2.x, p2.y)
			A0 = ((v0 - v1)*(p2.y-p1.y) - (v2 - v1)*(p0.y-p1.y))/((p0.x-p1.x)*(p2.y-p1.y) - (p2.x-p1.x)*(p0.y-p1.y))
			A1 = ((v0 - v1)*(p2.x-p1.x) - (v2 - v1)*(p0.x-p1.x))/((p0.y-p1.y)*(p2.x-p1.x) - (p2.y-p1.y)*(p0.x-p1.x))
			z = A0*p0.x+A1*p0.y - v0
			console.log("(A*p).x=%1~~z=%2 !!".arg(A0*p.x+A1*p.y).arg(z))
//			console.log("(A*p0).x=%1==v0+z=%2 !!".arg(A0*p0.x+A1*p0.y).arg(v0+z))
//			console.log("(A*p1).x=%1==v1+z=%2 !!".arg(A0*p1.x+A1*p1.y).arg(v1+z))
//			console.log("(A*p2).x=%1==v2+z=%2 !!".arg(A0*p2.x+A1*p2.y).arg(v2+z))

			var t = z/(A0*A0+A1*A1)
			var pz = Qt.point(A0*t, A1*t)

			op.append(pz.x, pz.y)

			console.log('---------------')
			var r = Math.sqrt(A0*A0+A1*A1)
			var c = A0/r, s = -A1/r
			rCoord.clear()
			rCoord.append(pz.x-c, pz.y+s)
			rCoord.append(pz.x+c, pz.y-s)
			rCoord.append(pz.x+s, pz.y+c)
			rCoord.append(pz.x, pz.y)
			rCoord.append(pp.x, pp.y)
			console.log('cos=%1,sin=%2,r=%3'.arg(c).arg(s).arg(r))
			console.log(p0, v0)
			console.log(p1, v1)
			console.log(p2, v2)
			console.log(pz, evaluate(pz.x, pz.y))

			if ((lastp.x-pz.x)*(lastp.x-pz.x)+(lastp.y-pz.y)*(lastp.y-pz.y)<1e-4) {
				var len = Math.sqrt((pp.x-pz.x)*(pp.x-pz.x)+(pp.y-pz.y)*(pp.y-pz.y))
				console.log("enough!")
				ToolTip.show("Iteration done:dis=%1".arg(len))
				return
			}
			lastp = pz

			v0 = Math.abs(v0)
			v1 = Math.abs(v1)
			v2 = Math.abs(v2)
			if (v0<v1)
				if (v1<v2)
					p2 = pz
				else
					p1 = pz
			else
				if (v0<v2)
					p2 = pz
				else
					p0 = pz
			if (counter<90)
				counter ++
		}
	}

	Button {
		anchors.left: step.right
		text: "auto"

		onClicked: {
			auto = true
			step.onClicked()
		}
	}
}
