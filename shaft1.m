
clear
clc
eq1=0 ; eq2=0 ;
Sy=370; %yield strength in MPa**************
Se=191; %endurance strength****************
Kf=1.9;%*********************
Kfs=1.7;%**************
FS=2.5; %******************
L=200; % distance of bearings******************
start_x=-65;%*********************
end_x=250;%**********************
N=400;% Number of X *******************
L2=end_x - start_x;
B1=sym('B1_%d',[1 3]);
B2=sym('B2_%d',[1 3]);
syms T1
F_value={[0.58,1.12,-3.48],[0,-0.26,0],[0,-0.90,0]}; % in KN****************
F_location={[-65,-46.5,0],[250,0,254],[250,0,-254]}; % in mm*******************
n_=size(F_value);
n=n_(2);
for i=1:n
    eq1=eq1 + F_value{i};
    eq2=eq2 + cross(F_location{i},F_value{i});
end
eq1=eq1 + B1 + B2==0;
eq2=eq2 + cross([L,0,0],B2) + [T1,0,0]==0;
solution=solve([eq1,eq2],[B1,B2,T1]);
% solution.B1_1=solution.B2_1;solution.B2_1=0;  %*****************************
solution.B2_1=solution.B1_1; solution.B1_1=0;  %*****************************
Torque=[];
for x=start_x:L2/N:end_x
    Torque1 =0;%[solution.T1,0,0];
    for i=1:n
        rel_loc=[F_location{i}(1)- x,F_location{i}(2),F_location{i}(3)];
        Torque1 = Torque1 + cross(rel_loc,F_value{i}) * heaviside(F_location{i}(1)- x);
    end
    Torque1 = Torque1 + heaviside(L-x)* double(cross([L-x,0,0],[solution.B2_1,solution.B2_2,solution.B2_3]));
   Torque =cat( 1 , Torque , Torque1 );
end

M=cat(2 ,transpose(start_x:L2/N:end_x) , sqrt( Torque(:,2).^2 + Torque (: ,3).^2 ));
T=cat(2 ,transpose(start_x:L2/N:end_x) ,Torque(:,1));

d1 =( (32*FS/pi)*1000* sqrt( Kf^2*(M(:,2)./Se).^2   +  Kfs^2 *(T(:,2)./Sy).^2  )).^(1/3); % for steps

d2= ( (32*FS/pi)*1000* sqrt( (M(:,2)./Se).^2   +  (T(:,2)./Sy).^2  )).^(1/3); % for non steps

plot(start_x:L2/N:end_x , d1,'b');
hold on
plot(start_x:L2/N:end_x , d2,'r');
xlabel('position on shaft in mm');
ylabel('diameter in mm');
title("Diamtere Shaft 1(x)");
legend({'d fo steps','d for non step'});
hold off
figure
plot(M(:,1) , M(:,2),'b');
xlabel('position on shaft in mm');
ylabel('Moment in N.m');
title("Moment 1(x) in N.m");
figure
plot(T(:,1) , T(:,2),'r');
xlabel('position on shaft in mm');
ylabel('Torque in N.m');
title("Torque 1(x) in N.m");


Force_B1=double([solution.B1_1,solution.B1_2,solution.B1_3]);
Force_B2=double([solution.B2_1,solution.B2_2,solution.B2_3]);



