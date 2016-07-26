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
		return (x*(x-.2) / 2.5 - 5) - y
//		return x*(x-1)+y*y-16
//		return Math.log(Math.abs(Math.tan(x/2))+.1)/2-y-2.
//		return Math.atan(Math.sin(x+2)*10-2)-y
//		return Math.sin(x)%.5-y+4
//		return (((((.3*x)+.8)*x-.2)*x+5)*2-12)*x-3-y
//		return Math.floor(x)-y-2.
//		return Math.exp(1./(Math.abs(x+.1)+.2))-y
//		return (-.9+x)/(.1+Math.abs(1.-x))-1.-y
//		return - x - y;
	}

	property real	c: 1.732*.5*.5
	property point pp: Qt.point(-0.9, 0.2)
	property point p0: Qt.point(pp.x,pp.y+c*2./3)
	property point p1: Qt.point(pp.x-c/2,pp.y-c/3)
	property point p2: Qt.point(pp.x+c/2,pp.y-c/3)
	property point lastp: pp

	property int counter: 0
	property bool auto: false

	onCounterChanged: if (auto) step.onClicked()

	Button {
		id: step
		text: "step" + counter

		function mix(a,b,u){
			return a*(1.-u)+b*u;
		}

		function len2(p0, p1) {
			return (p0.x-p1.x)*(p0.x-p1.x)+(p0.y-p1.y)*(p0.y-p1.y)
		}

		function len(p0, p1) {
			return Math.sqrt(len2(p0, p1))
		}

		function deval(p){
			var a = len2(p, pp)
			var b = evaluate(p.x, p.y);
			console.log("deval:", a, b)
//			return Math.pow(a+.2, .2)*b
			return b
		}

		function dot(p0, p1) {
			return p0.x*p1.x + p0.y*p1.y;
		}

		function mid(p0, p1) {
			return Qt.point((p0.x+p1.x)/2., (p0.y+p1.y)/2.)
		}

		function center(p0, p1, p2) {
			return Qt.point((p0.x+p1.x+p2.x)/3., (p0.y+p1.y+p2.y)/3.)
		}

		ToolTip.timeout: 1000
		onClicked: {
			console.log('===============')
			var v0, v1, v2, A0, A1, z, p, pz

			p = Qt.point(1., -1.)
			console.log("eval(%1)=%2==0 !!".arg(p).arg(evaluate(p.x, p.y)))
			console.log("deval(%1)=%2==0 !!".arg(p).arg(deval(p)))

			v0 = deval(p0)
			v1 = deval(p1)
			v2 = deval(p2)
			A0 = ((v0 - v1)*(p2.y-p1.y) - (v2 - v1)*(p0.y-p1.y))/((p0.x-p1.x)*(p2.y-p1.y) - (p2.x-p1.x)*(p0.y-p1.y))
			A1 = ((v0 - v1)*(p2.x-p1.x) - (v2 - v1)*(p0.x-p1.x))/((p0.y-p1.y)*(p2.x-p1.x) - (p2.y-p1.y)*(p0.x-p1.x))

			z = dot(lastp, Qt.point(A0, A1)) - deval(lastp)

			var refp
//			refp = pp
//			refp = lastp
//			refp = mid(pp, lastp)
			refp = center(p0, p1, p2)
//			refp = mid(pp, center(p0, p1, p2))
			console.log("z=", z)
			console.log("y=", -A1*refp.x+A0*refp.y)
			console.log("(A*p).x=%1~~z=%2 !!".arg(dot(p, Qt.point(A0, A1))).arg(z))
//			console.log("(A*p0).x=%1==v0+z=%2 !!".arg(A0*p0.x+A1*p0.y).arg(v0+z))
//			console.log("(A*p1).x=%1==v1+z=%2 !!".arg(A0*p1.x+A1*p1.y).arg(v1+z))
//			console.log("(A*p2).x=%1==v2+z=%2 !!".arg(A0*p2.x+A1*p2.y).arg(v2+z))

			var A2 = A0*A0+A1*A1
			pz = Qt.point(
					(A0*z+A1*A1*refp.x-A0*A1*refp.y)/A2,
					(A1*z-A0*A1*refp.x+A0*A0*refp.y)/A2
				)

			op.append(pz.x, pz.y)

			console.log('---------------')
			var r = Math.sqrt(A2)
			var c = A0/r, s = -A1/r
			rCoord.clear()
			rCoord.append(pz.x-c, pz.y+s) // x-
			rCoord.append(pz.x+c, pz.y-s) // x+
			rCoord.append(pz.x+s, pz.y+c) // y+

			rCoord.append(pz.x, pz.y)  // pz - pp
			rCoord.append(pp.x, pp.y)
			console.log('cos=%1,sin=%2,r=%3'.arg(c).arg(s).arg(r))
			console.log(p0, v0)
			console.log(p1, v1)
			console.log(p2, v2)
			console.log(pz, deval(pz), evaluate(pz.x, pz.y))
			console.log("len2(lastp, pz)=", len2(lastp, pz))

			if (len2(lastp, pz)<.25*.25) {
				var l = len(pp, pz)
				console.log("enough!")
				ToolTip.show("Iteration done:len=%1".arg(l))
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
