import("stdfaust.lib");

mth_octave_spectral_level6e(M,ftop,N,tau) = _<:  an.mth_octave_analyzer6e(M,ftop,N) : (display) with {
    display = par(i,N,dbmeter(i));
    dbmeter(i) = abs : si.smooth(ba.tau2pole(tau)) * 100: _ >4.0 :meter(N-i-1);
    meter(i) = _;
    O = int(((N-2)/M)+0.4999);
   
};

 speclevel_group(x)  = hgroup("[0] CONSTANT-Q SPECTRUM ANALYZER (6E), 7 bands spanningLP, 5 octaves below 4186 Hz, HP[tooltip: See Faust's filters.lib for documentation and references]", x);

mth_octave_spectral_level_default = mth_octave_spectral_level6e;

mth_octave_spectral_level_demo(BPO) =  mth_octave_spectral_level_default(M,ftop,N,tau)
with{
	M = BPO;
	ftop = 4186.01;
	Noct = 7; // number of octaves down from ftop
	// Lowest band-edge is at ftop*2^(-Noct+2) = 62.5 Hz when ftop=16 kHz:
	N = int(Noct*M); // without 'int()', segmentation fault observed for M=1.67
	ctl_group(x)  = hgroup("[1] SPECTRUM ANALYZER CONTROLS", x);
	tau = ctl_group(hslider("[0] Level Averaging Time [unit:ms] [scale:log] [tooltip: band-level averaging time in milliseconds]",500,1,10000,1)) * 0.001;

};
spectral_level_demo(hz, signal) = signal: mth_octave_spectral_level_demo(1); // 2/3 octave



power = hslider("value", 0, 0, 5, 1);
visualizeHz = _ <: attach(_, hbargraph("hz ",0,5000));
hz = 170*2^power: visualizeHz;

queBanda(herzios) = ba.if((herzios>=130.5) & (herzios<=261),1,0) + ba.if((herzios>=261) & (herzios<=523),2,0) + ba.if((herzios>=523.25) & (herzios<=1046.3),3,0) + ba.if((herzios>=1046.3) & (herzios<=2093),4,0) + ba.if((herzios>=2093) & (herzios>=1186),5,0);

voltear(a,s,d,f,g) = g,f,d,s,a; 
printar = !,_,_,_,_,_,!: voltear: par(i, 5, speclevel_group(vbargraph("[%1i] [tooltip: Spectral Band Level in dB]", 0.0, 100.0)));
media = _*256 + _*510 + _*1020 + _*2040 + _*4080: _ / 5:  _ <: attach(_, queBanda:hbargraph(" los hz que se generan ",0,5000));
//main
process = os.osc(hz): (spectral_level_demo: printar: media: os.osc) ~ (_); 