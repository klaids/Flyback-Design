clear;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	PROJECT SPECIFICATIONS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Input
Vin = 9;				% Input Voltage [V]

% Output
Vout = 5;				% Output Voltage [V]
Pout = 20;				% Output Power [V]

Fsw = 200e3;			% Switching frequency [Hz]
Tsw = 1/Fsw;			
MinLossPoint = 0.5;		% Load point with minimal losses [-] 

% Project Limits
Jrms = 4e6;				% Maximum current density [A/m^2]
Bac = 100e-3;			% Maximum magnetic field [T]
Kr = 0.7;				% Fill factor [-]
eta = 0.8;				% Efficiency  [-]
rho = 1.68e-8;			% Copper resistivity [Ohm*m]
mu0 = pi*4e-7;			% Vacuum permeability [H/m]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Pin = Pout/eta;			
Iout = Pout/Vout;		
CR = Vout/Vin;			% Conversion Ratio [-] 
D = 0.5;				% Choice of duty cycle [-]
TR = CR*(1-D)/D;		% Turn Ratio [-] 

Lm = 0.5*(1-D)*D*Vin*Tsw/(TR*Iout)  % Maximum magnetizing inductance [H] 
Ilmpk = Vin*D*Tsw/Lm;		% Peak current on inductance [A] 
Irms1 = Ilmpk*sqrt(D/3);	% Rms current on primary [A]

AeAw = (2*sqrt(D/3)*Pout)/(eta*Fsw*Bac*Jrms*Kr)		% Minimum AeAw [m^4]


%------------------------------------------------------------------------------%
%							DATA OF THE CHOSEN CORE

Ae = 31e-6;			% [m^2]
Aw = 26.4e-6;		% [m^2]
MLT = 36.5e-3;		% [m]
Veq = 1460e-9;		% Equivalent volume [m^3]
Pv1 = 80e3;			% Losses per unit of volume in the ferromagnetic core [W/m^3]
Pv2 = 450e3;		% Losses per unit of volume in the ferromagnetic core [W/m^3]
Bac1 = 100e-3;		
Bac2 = 200e-3;		
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
%							OPTIMIZATION 

IlmpkMLP = sqrt(2*Pout*MinLossPoint*Tsw/Lm);	% Peak current in the inductor at the point with minimum losses [A]
DMLP = IlmpkMLP*Fsw*Lm/Vin;						% Duty cycle value at the point with minimum losses [-]
Irms1MLP = IlmpkMLP*sqrt(DMLP/3);				% [A]

kBac = Vin*DMLP*Tsw*0.5/Ae;						% Coefficient between Field and number of turn [T*turn]
Beta = log(Pv1/Pv2)/log(Bac1/Bac2);				
Cb = Pv1/(Bac1^Beta);							% Coefficient between field and volume losses [w/(m^3*T^beta)]
kFe = Veq*Cb*kBac^Beta;							% Coefficient between iron losses and number of turn [W*turn^Beta]
	
kCu = 4*rho*MLT*(Irms1MLP^2)/(Aw*Kr);			% Coefficient between copper losses and number of turn [W/turn^2]

N = [1:1:50];

PlossCu = (N.^2)*kCu;				% [W]
PlossFe = kFe./(N.^Beta);			% [W]
PlossTot = PlossCu + PlossFe;		% Total losses as the number of turn [W]
[Pltot, N1opt] = min(PlossTot);		

N2opt = TR*N1opt;					% Number of turns to secondary [-]

Awire1 = 0.5*Aw*Kr/N1opt;				%  [m^2]
Dwire1 = 2*sqrt(Awire1/pi);				%  [m]
AWG1 = round(-39*log(Dwire1/0.127e-3)/log(92)+36);		%  [-]

Awire2 = 0.5*Aw*Kr/N2opt;				% Single wire section to the secondary [m^2]
Dwire2 = 2*sqrt(Awire2/pi);				% Single wire section to the primary [m]
AWG2 = round(-39*log(Dwire2/0.127e-3)/log(92)+36);		% [-]

Al = Lm/N1opt^2;					% inductance per turn^2 [H/turn^2]

Lg = mu0*Ae/Al;					% core gap [m]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	Results Graphs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


figure(1);
cla;
hold on;
grid on;
grid minor;

pCu = plot(N, PlossCu, 'r', 'DisplayName', 'Copper loss');	
pFe = plot(N, PlossFe, 'b', 'DisplayName', 'Iron loss');	
pTot = plot(N, PlossTot, 'k', 'DisplayName', 'Total losses');		

pMin = plot(N(N1opt), PlossTot(N1opt), 'ro');					
optTurn = plot([N1opt N1opt],[0 max(PlossTot)], 'k-.');			
text(N1opt, 0.007, ['N_{1}^{OPT} = ', num2str(N1opt), ' turn'], 'FontSize', 12);
minLoss = plot([0 max(N)],[Pltot Pltot], 'k-.');        		
text(10, (Pltot-0.005), ['P_{LOSS} = ', num2str(Pltot), ' W'],'FontSize', 12);

legend({},'Location', 'northeast')								
axis ([0 30 0 0.25]);											
title('Core Loss', 'FontSize', 16);					
xlabel('Number of turns to primary [-]', 'FontSize', 16);			
ylabel('Power Loss [W]', 'FontSize', 16);							
hold off;
