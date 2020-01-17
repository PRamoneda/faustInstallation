import("stdfaust.lib");
//GUI
declare interface "SmartKeyboard{
	'Number of Keyboards':'1',
	'Max Keyboard Polyphony':'0',
	'Keyboard 0 - Number of Keys':'1',
	'Keyboard 0 - Send Freq':'0',
	'Keyboard 0 - Static Mode':'0',
	'Keyboard 0 - Piano Keyboard':'0',
	'Keyboard 0 - Key 0 - Label':'Press to PLAY',
	'Keyboard 0 - Send Key Status':'1'
}";
// map
kb0k0status = hslider("kb0k0status",0,0,4,1);
play = kb0k0status >= 1;
// sensors
acelerometroAmplitud= hslider("acelerometroAmplitud[acc: 1 0 -10 0 10]",1,0.001,8,0.001) : si.smoo; 
acelerometroFrecuency= hslider("acelerometroFrecuency[acc: 0 0 -10 0 10]",0,-15,20,1) : si.smoo; 
sensors = _, acelerometroFrecuency: +;
//tabla
tabla = rwtable(2, 1000.0,int(pulsos),_,int(pulsos))with{
    initValue = 1000.0;
    pulsos = os.lf_rawsaw(44100) < 0;
};


process = (tabla: sensors:max(131)) ~ (_: si.smooth(ba.tau2pole(0.01))) : hbargraph("HZ ",0,5): os.osc*play*acelerometroAmplitud;