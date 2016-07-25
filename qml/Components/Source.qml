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
#define xy	(vec2(x,y))
#define xyt	(vec3(x,y,t))
#define r	(length(xy))
varying vec2 qt_TexCoord0;

uniform float qt_Opacity;
uniform float t;
uniform vec4 range;

FP float s=sin(t*PI*2.);
FP float c=cos(t*PI*2.);
FP vec2 rt=vec2(c,s);

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
#define xy	(vec2(x,y))
#define xyt	(vec3(x,y,t))
#define r	(length(xy))
varying vec2 qt_TexCoord0;

uniform float qt_Opacity;
uniform float t;
uniform vec4 range;
uniform float lw;
uniform vec4 lc;
uniform vec4 ac;

uniform float _width;

FP float s=sin(t*PI*2.);
FP float c=cos(t*PI*2.);
FP vec2 rt=vec2(c,s);

FP float ep0=(range.y-range.x)*lw/_width;
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
	if (s<v*8.) s=v*8.;
	return eval(x,y)>0.?mix(lc, ac, v*8./s):(1.-v*8./s) * lc;
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
#define xy	(vec2(x,y))
#define xyt	(vec3(x,y,t))
#define r	(length(xy))
varying vec2 qt_TexCoord0;

uniform float qt_Opacity;
uniform float t;
uniform vec4 range;
uniform float lw;
uniform vec4 lc;
uniform vec4 ac;
uniform bool extra0;

uniform float _width;

FP float s=sin(t*PI*2.);
FP float c=cos(t*PI*2.);
FP vec2 rt=vec2(c,s);

const FP float c1 = 0.923879532511;
const FP float c2 = 0.707106781187;
const FP float c3 = 0.382683432365;

FP float ep1=(range.y-range.x)/_width;
FP float ep3=ep1*(lw+1.)/2.;

%2

FP float eval(FP float x, FP float y) {
	return (%1);
}

FP vec4 color(FP float x, FP float y){

	FP float v[16];
	FP vec4 c;

	v[0]  = eval(x+ep3, y);
	v[1]  = eval(x+ep3*c1, y+ep3*c3);
	v[2]  = eval(x+ep3*c2, y+ep3*c2);
	v[3]  = eval(x+ep3*c3, y+ep3*c1);
	v[4]  = eval(x, y+ep3);
	v[5]  = eval(x-ep3*c3, y+ep3*c1);
	v[6]  = eval(x-ep3*c2, y+ep3*c2);
	v[7]  = eval(x-ep3*c1, y+ep3*c3);
	v[8]  = eval(x-ep3, y);
	v[9]  = eval(x-ep3*c1, y-ep3*c3);
	v[10] = eval(x-ep3*c2, y-ep3*c2);
	v[11] = eval(x-ep3*c3, y-ep3*c1);
	v[12] = eval(x, y-ep3);
	v[13] = eval(x+ep3*c3, y-ep3*c1);
	v[14] = eval(x+ep3*c2, y-ep3*c2);
	v[15] = eval(x+ep3*c1, y-ep3*c3);

	float s = sign(v[0]);

	int i, j;
	for (i=15;i>0;i--) if (sign(v[i])!=s) break;
	if (i != 0) { // i~i+1
		for (j=i-1;j>0;j--) if (sign(v[j])==s) break;
		// j~j+1
		float dis = float(i-j);
		// uncomment to get higher AA (+1 order)
		if (extra0)
			dis += v[i]/(v[i]-v[i==15?0:i+1])-v[j]/(v[j]-v[j+1]);
		if (dis>8.) dis = 16.-dis;

		float o = 1.-cos(dis*PI/16.);
		c = (eval(x,y)>0.)?mix(ac, lc, clamp(o, 0., 1.)):
			clamp(o, 0., 1.) * lc;
	}
	else
		c = (eval(x,y)>0.)?ac:vec4(0.);
//		c = vec4(0.);

	return c;
}

void main() {
FP float x = mix(range.x, range.y, qt_TexCoord0.x);
FP float y = mix(range.w, range.z, qt_TexCoord0.y);
gl_FragColor = color(x, y) * qt_Opacity;
}
"

	readonly property string newtonSource:"
"


}
