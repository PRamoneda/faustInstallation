# faustInstallation
A faust music installation for sound synthesis subject, FEUP-Universdade do Porto 2019-2020.  

# Diálogos Móbiles 

![](https://i.imgur.com/nTLgK7U.png)

>>A **multi-agent system** (MAS or "self-organized system") is a computerized system composed of multiple interacting intelligent agents. Multi-agent systems can solve problems that are difficult or impossible for an individual agent or a monolithic system to solve. Intelligence may include methodic, functional, procedural approaches, algorithmic search or reinforcement learning.

After exploring the idea of ​​making a multi-agent system, mixing the language to make faust sound engines with other high-level language and embedded systems. It has been rememberer that the most powerful computational system is the human brain, since it is infinitely parallelizable. And if more humans are used, it can be parallelized to infinity, as a social experience.

Using the ability of humans to interact with each other. An attempt was made to augment it by a mobile interface. That is why every human is a sound distributed agent in this project. 

Then, new skills are added to the human to be able to relate in this new way of communication. Basically there are three augmented reality options: passive, active and mixed.

In the **passive interface**, it allows you to listen to the sounds that you have around and from there generate new sounds.

![](https://i.imgur.com/ffMTQD5.png)

In the **active interface**, it allows you to generate new sounds from the gyros of the mobile. Each human has a sound from which he starts and to change it he turns it forward if he wants it to be more *grave* and back if he wants it more *agudo*. He turns it to the right if he wants more *piano* and to the left if he wants it more *fuerte*.

![](https://i.imgur.com/7QDzNRs.png)

The **mixed interface** mixes the two previous experiences.

![](https://i.imgur.com/Vg4AYt4.png)

References: https://www.mdpi.com/2076-3417/7/12/1311

## Technical learning

**Faust** is a very powerfull language in order to make sound engines. However, it is a mixture between a functional language (as Haskell) and a declarative language (as Verilog). Due to that fact we can say that this is a very very hard laguage in order to learn and debug.


Numerous hours have been spent just to learn the language, more than 40 hours. Although, it is true that, if a correct path had been followed from the beginning, it could have been done faster.

The perfect learning path would be now this one:

- Watch **only** the videos of KADENZE MOOC (https://www.kadenze.com/courses/real-time-audio-signal-processing-in-faust/info)

{%youtube Dz8_NwxhAAY %}

- To code all the tutorials of Romain Michon(https://ccrma.stanford.edu/~rmichon/faustTutorials/#using-built-in-sensors-and-implementing-xy-controllers-making-sound-toys)

- Study very hard documentation of faust and libraries
(https://github.com/grame-cncm/faust)
(https://github.com/grame-cncm/faustlibraries)
(https://faust.grame.fr/doc/manual/index.html)
(http://faust.grame.fr/editor/libraries/doc/library.html)
(https://faust.grame.fr/tools/editor/libraries/doc/library.pdf)
(https://github.com/grame-cncm/fausteditorweb)

- Join to the slack group of faust and ask your questions.
- Dicover all the tools of the faust world (there are too much)


To sum up, keep in mind that it is very difficult to deploy on any platform, although, it is still a hundred times easier than if you did it in C.


# Thechnical report

## Passive agent 

<iframe width="100%" height="100%" src="./passiveAgent-svg/process.svg" frameborder="0"></iframe>

(Diagram is interactive!!!!!)


An *analysis* is made by the constant q transform. This allows you to divide the wave into several octaves. From what is sounding around you is generated a simple sine oscillator. In addition, the band in which the sound is generated is not analyzed by means of a feedback.

To achieve a good user experience, a large number of transformations are performed from linear to logarithmic and vice versa, as well as many smoothing functions.

```
import("stdfaust.lib");

mth_octave_spectral_level6e(M,ftop,N,tau, banda) = _<:  an.mth_octave_analyzer6e(M,ftop,N) : (display) with {
    display = par(i,N,dbmeter(i));
    dbmeter(i) = abs : si.smooth(ba.tau2pole(tau)) * 100: _ >4.0 :meter(N-i-1);
  	anuleBand(i, sig) = ba.if(i ==  banda, 0, sig);
    meter(i) = _ :anuleBand(i);
    O = int(((N-2)/M)+0.4999);
};




mth_octave_spectral_level_demo(BPO, banda) =  mth_octave_spectral_level6e(M,ftop,N,tau, banda)
with{
	M = BPO;
	ftop = 4186.01;
	Noct = 7; // number of octaves down from ftop
	// Lowest band-edge is at ftop*2^(-Noct+2) = 62.5 Hz when ftop=16 kHz:
	N = int(Noct*M); // without 'int()', segmentation fault observed for M=1.67
	ctl_group(x)  = hgroup("[1] SPECTRUM ANALYZER CONTROLS", x);
	tau = ctl_group(hslider("[0] Level Averaging Time [unit:ms] [scale:log] [tooltip: band-level averaging time in milliseconds]",500,1,10000,1)) * 0.001;

};
spectral_level_demo(banda, signal) = signal: mth_octave_spectral_level_demo(1, banda); // 2/3 octave


//Funciones para probar sin sonido de fuera
power1 = hslider("value1", 0, 0, 5, 1);
visualizeHz1 = _ <: attach(_, hbargraph("hz 1",0,5000));
herzios1 = 170*2^power1: visualizeHz1;

power2 = hslider("value2", 0, 0, 5, 1);
visualizeHz2 = _ <: attach(_, hbargraph("hz 2",0,5000));
herzios2 = 170*2^power2: visualizeHz2;
//END Funciones para probar sin sonido de fuera

queBanda(hz) = ba.if((hz>=130.5) & (hz<261),1,0) + ba.if((hz>=261) & (hz<523),2,0) + ba.if((hz>=523.25) & (hz<1046.3),3,0) + ba.if((hz>=1046.3) & (hz<2093),4,0) + ba.if((hz>=2093) & (hz<4186),5,0);

inRange = _: max(131): min(4185);
voltear(a,s,d,f,g) = g,f,d,s,a; 
printar = !,_,_,_,_,_,!: voltear: par(i, 5, speclevel_group(vbargraph("[%1i] [tooltip: Spectral Band Level in dB]", 0.0, 100.0)));
speclevel_group(x)  = hgroup("[0] CONSTANT-Q SPECTRUM ANALYZER (6E), 7 bands spanningLP, 5 octaves below 4186 Hz, HP[tooltip: See Faust's filters.lib for documentation and references]", x);

formula(a,s,d,f,g) = (a*256 + s*510 + d*1020 + f*2040 + g*4080) , (ba.if(((a+s+d+f+g)== 0),1,(a+s+d+f+g))):ma.log2,_ : / : 2^_ : inRange: _ <: attach(_, hbargraph("Los hz que se estan generando ",0,5000));


// main functions
analizador = spectral_level_demo: printar: formula:si.smooth(ba.tau2pole(2));
recursividad = _:queBanda:hbargraph("La banda en la que se estan generando ",0,5);
// GUI 
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
//main
process = _: (analizador) ~ (recursividad): os.osc*play; 
```
## Active agent
<iframe width="100%" height="100%" src="./activeAgent-svg/process.svg" frameborder="0"></iframe>

(Diagram is interactive!!!!!)


This agent basically focuses on the person-computer interface. Allowing to control the tone and intensity. In addition, a table is used to save the value that is generated. This achieves a very interesting user experience that has cost a lot to generate, due to the limitations of the language. Gaussians are also used to smooth signal transitions.

```
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
```

## Mixed agent

<iframe width="100%" height="100%" src="./passiveAndActiveAgent-svg/process.svg" frameborder="0"></iframe>

(Diagram is interactive!!!!!)

A mixture between passive agent and active agent.
```
import("stdfaust.lib");

mth_octave_spectral_level6e(M,ftop,N,tau, banda) = _<:  an.mth_octave_analyzer6e(M,ftop,N) : (display) with {
    display = par(i,N,dbmeter(i));
    dbmeter(i) = abs : si.smooth(ba.tau2pole(tau)) * 100: _ >4.0 :meter(N-i-1);
  	anuleBand(i, sig) = ba.if(i ==  banda, 0, sig);
    meter(i) = _ :anuleBand(i);
    O = int(((N-2)/M)+0.4999);
};




mth_octave_spectral_level_demo(BPO, banda) =  mth_octave_spectral_level6e(M,ftop,N,tau, banda)
with{
	M = BPO;
	ftop = 4186.01;
	Noct = 7; // number of octaves down from ftop
	// Lowest band-edge is at ftop*2^(-Noct+2) = 62.5 Hz when ftop=16 kHz:
	N = int(Noct*M); // without 'int()', segmentation fault observed for M=1.67
	ctl_group(x)  = hgroup("[1] SPECTRUM ANALYZER CONTROLS", x);
	tau = ctl_group(hslider("[0] Level Averaging Time [unit:ms] [scale:log] [tooltip: band-level averaging time in milliseconds]",500,1,10000,1)) * 0.001;

};
spectral_level_demo(banda, signal) = signal: mth_octave_spectral_level_demo(1, banda); // 2/3 octave


//Funciones para probar sin sonido de fuera
power1 = hslider("value1", 0, 0, 5, 1);
visualizeHz1 = _ <: attach(_, hbargraph("hz 1",0,5000));
herzios1 = 170*2^power1: visualizeHz1;

power2 = hslider("value2", 0, 0, 5, 1);
visualizeHz2 = _ <: attach(_, hbargraph("hz 2",0,5000));
herzios2 = 170*2^power2: visualizeHz2;
//END Funciones para probar sin sonido de fuera

queBanda(hz) = ba.if((hz>=130.5) & (hz<261),1,0) + ba.if((hz>=261) & (hz<523),2,0) + ba.if((hz>=523.25) & (hz<1046.3),3,0) + ba.if((hz>=1046.3) & (hz<2093),4,0) + ba.if((hz>=2093) & (hz<4186),5,0);

inRange = _: max(131): min(4185);
voltear(a,s,d,f,g) = g,f,d,s,a; 
printar = !,_,_,_,_,_,!: voltear: par(i, 5, speclevel_group(vbargraph("[%1i] [tooltip: Spectral Band Level in dB]", 0.0, 100.0)));
speclevel_group(x)  = hgroup("[0] CONSTANT-Q SPECTRUM ANALYZER (6E), 7 bands spanningLP, 5 octaves below 4186 Hz, HP[tooltip: See Faust's filters.lib for documentation and references]", x);

formula(a,s,d,f,g) = (a*256 + s*510 + d*1020 + f*2040 + g*4080) , (ba.if(((a+s+d+f+g)== 0),1,(a+s+d+f+g))):ma.log2,_ : / : 2^_ : inRange: _ <: attach(_, hbargraph("Los hz que se estan generando ",0,5000));


// main functions
analizador = spectral_level_demo: printar: formula:si.smooth(ba.tau2pole(2));
recursividad = _:queBanda:hbargraph("La banda en la que se estan generando ",0,5);
/////////////////// GUI ///////////////////////////////////
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



/////////////////////////////////////////////////////////////////////
//main
passive = _: (analizador) ~ (recursividad) ; 
saveTable = si.smooth(ba.tau2pole(0.01));

process = (tabla, _: sensors*0.7, passive*0.3: + : inRange) ~ (saveTable): os.osc*play*acelerometroAmplitud;


```
