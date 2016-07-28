pragma Singleton

import QtQuick 2.0

QtObject {
	id: root


	readonly property ListModel modeList: ListModel {
		ListElement { text: "Color Plot" }
		ListElement { text: "8x Value AA Line Plot" }
		ListElement { text: "16x Distance AA Line Plot" }
		ListElement { text: "8-bit Newton Iter AA Line Plot" }
	}

	function get(mode) {
		switch (mode) {
		case 1: return simpleSource
		case 2: return roundSource
		case 3: return newtonSource
		default: return colorSource
		}
	}

	readonly property string colorSource:"
#define FP	highp
#define PI	3.14159265359
#define xy2	(vec2(x,y))
#define xyt	(vec3(x,y,t))
#define lxy	(length(xy2))
varying vec2 qt_TexCoord0;

uniform float qt_Opacity;
uniform float t;
uniform vec4 range;

FP float s=sin(t*PI*2.);
FP float c=cos(t*PI*2.);
FP vec2 rt=vec2(c,s);
FP mat2 rot2=mat2(c, -s, s, c);

%2

FP vec3 eval(FP float x, FP float y) {
	return vec3(%1);
}

void main() {
	FP float x = mix(range.x, range.y, qt_TexCoord0.x);
	FP float y = mix(range.w, range.z, qt_TexCoord0.y);
	gl_FragColor = vec4(eval(x, y), 1.) * qt_Opacity;
}
"

	readonly property string simpleSource:"
#define FP	highp
#define PI	3.14159265359
#define xy2	(vec2(x,y))
#define xyt	(vec3(x,y,t))
#define lxy	(length(xy2))
varying vec2 qt_TexCoord0;

uniform float qt_Opacity;
uniform float t;
uniform vec4 range;
uniform float lw;
uniform vec4 lc;
uniform vec4 ac;

uniform float _width;
uniform bool flag1;
uniform bool flag2;

FP float s=sin(t*PI*2.);
FP float c=cos(t*PI*2.);
FP vec2 rt=vec2(c,s);
FP mat2 rot2=mat2(c, -s, s, c);

FP float ep0=(range.y-range.x)*lw/_width/2.;
FP float ep1=(range.y-range.x)*(lw+1.)/_width/2.;
const FP float eps=1e-8;

%2

FP float eval(FP float x, FP float y) {
	return (%1);
}

FP vec4 color(FP float x, FP float y){
	FP float dx, dy;
	FP float v=abs(eval(x,y));
	FP float s=0.;
	for (dx=-ep0;dx<=ep0;dx+=ep0){
		for (dy=-ep0;dy<=ep0;dy+=ep0){
			s+=abs(eval(x+dx,y+dy));
		}
	}

	s-=v;
	if (v<eps) v=eps;
	if (flag1)
		if (flag2)
			s = pow(clamp((1.-v*8./s)/ep1, 0., 1.), clamp(lw, 1., 30.)); // original space enhanced
		else
			s = clamp((1.-v*8./s)/ep1, 0., 1.); // original space
	else
		s = clamp((1.-v*8./s), 0., 1.);//blur version

	return eval(x,y)>0.?mix(ac, lc, s):s * lc;
}

void main() {
	FP float x = mix(range.x, range.y, qt_TexCoord0.x);
	FP float y = mix(range.w, range.z, qt_TexCoord0.y);
	gl_FragColor = color(x, y) * qt_Opacity;
}
"

	readonly property string roundSource:"
#define FP	highp
#define PI	3.14159265359
#define xy2	(vec2(x,y))
#define xyt	(vec3(x,y,t))
#define lxy	(length(xy2))
varying vec2 qt_TexCoord0;

uniform float qt_Opacity;
uniform float t;
uniform vec4 range;
uniform float lw;
uniform vec4 lc;
uniform vec4 ac;
uniform bool flag0;

uniform float _width;

FP float s=sin(t*PI*2.);
FP float c=cos(t*PI*2.);
FP vec2 rt=vec2(c,s);
FP mat2 rot2=mat2(c, -s, s, c);

const FP float c1 = 0.923879532511;
const FP float c2 = 0.707106781187;
const FP float c3 = 0.382683432365;

FP float ep1=(range.y-range.x)/_width;
FP float ep2=ep1*(lw+1.)/2.;
FP float ep3=ep1*(lw/2.+1.);

%2

FP float eval(FP float x, FP float y) {
	return (%1);
}

FP vec4 color(FP float x, FP float y){

	FP float v[16];
	FP vec4 c;

	v[0]  = eval(x+ep2, y);
	v[1]  = eval(x+ep2*c1, y+ep2*c3);
	v[2]  = eval(x+ep2*c2, y+ep2*c2);
	v[3]  = eval(x+ep2*c3, y+ep2*c1);
	v[4]  = eval(x, y+ep2);
	v[5]  = eval(x-ep2*c3, y+ep2*c1);
	v[6]  = eval(x-ep2*c2, y+ep2*c2);
	v[7]  = eval(x-ep2*c1, y+ep2*c3);
	v[8]  = eval(x-ep2, y);
	v[9]  = eval(x-ep2*c1, y-ep2*c3);
	v[10] = eval(x-ep2*c2, y-ep2*c2);
	v[11] = eval(x-ep2*c3, y-ep2*c1);
	v[12] = eval(x, y-ep2);
	v[13] = eval(x+ep2*c3, y-ep2*c1);
	v[14] = eval(x+ep2*c2, y-ep2*c2);
	v[15] = eval(x+ep2*c1, y-ep2*c3);

	FP float s = sign(v[0]);

	int i, j;
	for (i=15;i>0;i--) if (sign(v[i])!=s) break;
	if (i != 0) { // i~i+1
		for (j=i-1;j>0;j--) if (sign(v[j])==s) break;
		// j~j+1
		FP float dis = float(i-j);
		// uncomment to get higher AA (+1 order)
		if (flag0)
			dis += v[i]/(v[i]-v[i==15?0:i+1])-v[j]/(v[j]-v[j+1]);
		if (dis>8.) dis = 16.-dis;

		FP float o = clamp((1.-cos(dis*PI/16.))/ep3, 0., 1.);
		//o = dis*PI/16.;
		c = (eval(x,y)>0.)?mix(ac, lc, o):o*lc;
	}
	else
		c = (eval(x,y)>0.)?ac:vec4(0.);

	return c;
}

void main() {
	FP float x = mix(range.x, range.y, qt_TexCoord0.x);
	FP float y = mix(range.w, range.z, qt_TexCoord0.y);
	gl_FragColor = color(x, y) * qt_Opacity;
}
"

	readonly property string newtonSource:"
#define FP	highp
#define PI	3.14159265359
#define xy2	(vec2(x,y))
#define xyt	(vec3(x,y,t))
#define lxy	(length(xy2))
varying vec2 qt_TexCoord0;

uniform float qt_Opacity;
uniform float t;
uniform vec4 range;
uniform float lw;
uniform vec4 lc;
uniform vec4 ac;

uniform float _width;
uniform bool flag2;

FP float s=sin(t*PI*2.);
FP float c=cos(t*PI*2.);
FP vec2 rt=vec2(c,s);
FP mat2 rot2=mat2(c, -s, s, c);

const FP float c1 = 1.732 * .0625;
int MAXITER = 16; // can be override

FP float hw=(lw+1.)/2.;
FP float ep1=(range.y-range.x)/_width;
FP float ep0=ep1/128.;
FP float ep2=c1*ep1;
FP float ep3=ep1*hw;

%2

FP float eval(FP float x, FP float y) {
	return (%1);
}

FP vec4 color(FP float x, FP float y){
	int n = MAXITER;
	FP vec2 p0, p1, p2, pz, sp, pp, rp;
	FP float v0, v1, v2, a0, a1, a01, a02, a12, z, t;

	p0 = vec2(x, y+ep2*2./3.);
	p1 = vec2(x-ep2/2., y-ep2/3.);
	p2 = vec2(x+ep2/2., y-ep2/3.);
	sp = vec2(x, y);
	pp = sp;

	while (n>0) {
		rp = (p0+p1+p2)/3.;
		v0 = eval(p0.x, p0.y);
		v1 = eval(p1.x, p1.y);
		v2 = eval(p2.x, p2.y);
		a0 = ((v0 - v1)*(p2.y-p1.y) - (v2 - v1)*(p0.y-p1.y))/
			((p0.x-p1.x)*(p2.y-p1.y) - (p2.x-p1.x)*(p0.y-p1.y));
		a1 = ((v0 - v1)*(p2.x-p1.x) - (v2 - v1)*(p0.x-p1.x))/
			((p0.y-p1.y)*(p2.x-p1.x) - (p2.y-p1.y)*(p0.x-p1.x));
		a02 = a0*a0;
		a12 = a1*a1;
		a01 = a0*a1;

		z = a0*pp.x+a1*pp.y - eval(pp.x, pp.y);
		//z = a0*p0.x+a1*p0.y - v0;
		pz = vec2(a0*z+a12*rp.x-a01*rp.y, a1*z-a01*rp.x+a02*rp.y);
		pz /= a02+a12;

		if (distance(pp, pz)<ep0)
			break;
		else {
			pp = pz;
			v0 = abs(v0);
			v1 = abs(v1);
			v2 = abs(v2);
			if (v0<v1)
				if (v1<v2)
					p2 = pz;
				else
					p1 = pz;
			else
				if (v0<v2)
					p2 = pz;
				else
					p0 = pz;
			n--;
		}
	}

	pz = (pz+pp)/2.;
	FP float o;
	if (flag2) // debug
		o = float(n)/float(MAXITER);
		//o = z;
	else
		o = hw-distance(sp, pz)/ep1;
	FP vec4 c = (eval(x,y)>0.)?mix(ac, lc, clamp(o, 0., 1.)):
		clamp(o, 0., 1.) * lc;

	return c;
//	return vec4(a0, a1, 0., 1.);
}

void main() {
	FP float x = mix(range.x, range.y, qt_TexCoord0.x);
	FP float y = mix(range.w, range.z, qt_TexCoord0.y);
	gl_FragColor = color(x, y) * qt_Opacity;
}
"


}
