%%%RCD-Snubber Calculator for Flyback Converters%%%

VOutVf = 12.7;   %Vout + Vf [V]
Np_s = 1;        %Np/Ns 
Lleak = 1e-6;    %L Leakage [H]
Im_pri = 1.5;    % [A]
fsw =  200e3;    % [Hz]
Ksnub = 1.5; %Vsnub is the reflected output voltage plus the permitted overshoot caused by transformer leakage
             %inductance and switching node parasitics. Thus Ksnub has a value greater than 1.
DVSnub = 10;     %  [%] 

Vsnub = Ksnub*Np_s*VOutVf

Rsnub = (Vsnub)^2/(0.5 * Lleak * Im_pri^2 * (Vsnub)/(Vsnub-Np_s*VOutVf)* fsw)

Csnub = Vsnub/( (DVSnub/100) * Vsnub * Rsnub * fsw )



