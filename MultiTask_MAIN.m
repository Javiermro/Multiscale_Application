% *************************************************************************
% MULTISCALE PROGRAM - MAIN FILE
% *************************************************************************
clc; clear all; close all
% ********* TESTS **********
TEST_DATA(1).nLab = 1;
main_example_path = '/home/javiermro/Projects/Examples'; 
TEST_DATA(1).path_file= [main_example_path '/StructHole10/Mi_GD_J2_StructHole']; TEST_DATA(1).file = 'RVE_StructHole10.mfl' ; %'RVE_Hole05.mfl';%

% TEST_DATA(1).path_file= 'C:/CIMNE/Codes/MultiScale_SantaFe/Examples/RVE_Struct_Hole_01/Mi_GD_J2'; TEST_DATA(1).file = 'RVE_Struct_Hole.mfl' ;
% TEST_DATA(1).path_file= 'C:/CIMNE/Kratos/4ELEM_MICRO bbar'; TEST_DATA(1).file = 'meso_cell_RandIncPlastJ2.mfl';
% TEST_DATA(1).path_file= 'C:/CIMNE/Codes/MultiScale_SantaFe/Examples/MS_Probeta01/MS_GD_J2_Prob01'; TEST_DATA(1).file = 'Macro.mfl';
% TEST_DATA(1).path_file= 'C:/CIMNE/Codes/MultiScale_SantaFe/Examples/RVE_Alloy01/Mi_GD_J2_Alloy01';
% TEST_DATA(1).path_file= 'C:/CIMNE/Codes/MultiScale_SantaFe/Examples/RVE_Hole_03/Mi_GD_J2_Hole'; TEST_DATA(1).file = 'RVE_Hole03.mfl'
% TEST_DATA(1).path_file= 'C:/CIMNE/Codes/MultiScale_SantaFe/Examples/RVE_Hole_05/Mi_GD_J2_Hole'; TEST_DATA(1).file = 'RVE_Hole05.mfl' ;
% TEST_DATA(1).path_file= 'C:/CIMNE/Codes/MultiScale_SantaFe/Examples/RVE_RigidHole_05/Mi_GD_J2_RigidHole'; TEST_DATA(1).file = 'RVE_Hole05.mfl';
% TEST_DATA(1).path_file= 'C:/CIMNE/Codes/MultiScale_SantaFe/Examples/RVE_RigidHole_04/Mi_GD_J2_RigidHole'; TEST_DATA(1).file = 'RVE_Hole04.mfl'
% TEST_DATA(1).path_file= 'C:/CIMNE/Codes/MultiScale_SantaFe/Examples/RVE_RigidHole_03/Mi_GD_J2_RigidHole'; TEST_DATA(1).file = 'RVE_Hole03.mfl'
% TEST_DATA(1).path_file= 'C:/CIMNE/Codes/MultiScale_SantaFe/Examples/TEST13/Mi_GD_J2';  TEST_DATA(1).file = 'RVE5X5_Periodico.mfl';
% TEST_DATA(1).path_file= 'C:/CIMNE/Codes/MultiScale_SantaFe/Examples/MS_PD_J2_Snapshots';  TEST_DATA(1).file = 'Macro.mfl';
% TEST_DATA(1).file = 'Macro.mfl'; %'RVE_Hole3_Periodico.mfl'; %'RVE_Hole05_Periodico.mfl'; %'RVE_Alloy01.mfl'; %'RVE5X5_Periodico.mfl'; %'RVE_Hole_Periodico_Elas.mfl'; %'Macro.mfl'; % 'RVE11_Periodico.mfl'; %
% isMICRO(1).MICRO =0; % For macro & multiscale models
isMICRO(1).MICRO =1; FACT = 1; % For RVE analysis
% isMICRO(1).epsilon_Macro0=FACT*[.01; 0; 0; .01]

%% RVE_Struct_Hole_10 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isMICRO(1).epsilon_Macro0=FACT*[0.2; 0; 0; 0; 0] ; %ne10
% isMICRO(1).epsilon_Macro0=FACT*[ 0; -0.2; 0; 0; 0] ; %ne10
% isMICRO(1).epsilon_Macro0=FACT*[ 0; 0; 0; 0.4; 0] ; %ne9
%% RVE_Rigid_Hole_Periodico %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% isMICRO(1).epsilon_Macro0=FACT*[-0.23; 0; 0; 0; 0]; % Modo01   ne9 ne8 ne9
% isMICRO(1).epsilon_Macro0=FACT*[0; 0.15; 0; 0; 0]; % Modo02  ne14 ne13 ne9
% isMICRO(1).epsilon_Macro0=FACT*[0; 0; 0; 0.25; 0]; % Modo03  ne10 ne9 ne9 Hay que cambiar las funciones de carga en .mfl
% isMICRO(1).epsilon_Macro0=FACT*[0.15; -0.15; 0; 0; 0]; % Modo04  ne9 ne9 ne9
% isMICRO(1).epsilon_Macro0=FACT*[0.2; 0; 0; 0.1; 0]; % Modo05  ne10 ne9 ne10
% isMICRO(1).epsilon_Macro0=FACT*[0.1; -0.1; 0; 0.2; 0]; % Modo06 ne10 ne10 ne9
% isMICRO(1).epsilon_Macro0=FACT*[0.1; 0.1; 0; 0; -0.2]; % Modo07 ne9 ne8 ne9
% isMICRO(1).epsilon_Macro0=FACT*[-0.14; -0.14; 0; 0; 0]; % Modo08 ne12 ne11 ne9
% isMICRO(1).epsilon_Macro0=FACT*[-0.2; 0.1; 0; -0.1; -0.1]; % TRAYECTORIA NO ENTRENADA
%% RVE_Hole03 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% isMICRO(1).epsilon_Macro0=FACT*[0.06; 0; 0; 0; 0]; % Modo01 ne22
% isMICRO(1).epsilon_Macro0=FACT*[0; -0.06; 0; 0; 0]; % Modo02 ne23
% isMICRO(1).epsilon_Macro0=FACT*[0; 0; 0; 0.14; 0]; % Modo03 ne18
% isMICRO(1).epsilon_Macro0=FACT*[-0.06; 0.06; 0; 0; 0]; % Modo04 ne22
% isMICRO(1).epsilon_Macro0=FACT*[0.05; 0; 0; 0.05; 0]; % Modo05 ne22
% isMICRO(1).epsilon_Macro0=FACT*[0.05; -0.05; 0; 0.05; 0]; % Modo06 ne23
% isMICRO(1).epsilon_Macro0=FACT*[0.03; 0.03; 0; -0.05; 0.0]; % Modo07 ne24
% isMICRO(1).epsilon_Macro0=FACT*[-0.05; -0.05; 0; 0.0; 0.0]; % Modo08 ne25
% isMICRO(1).epsilon_Macro0=FACT*[0.07; 0; 0; 0.1; 0]; % Modo17
%% RVE_Hole05 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% isMICRO(1).epsilon_Macro0=FACT*[0.07; 0; 0; 0; 0]; % Modo01  ne22
% isMICRO(1).epsilon_Macro0=FACT*[0; -0.1; 0; 0; 0]; % Modo02  ne16
% isMICRO(1).epsilon_Macro0=FACT*[0; 0; 0; 0.25; 0]; % Modo03    ne12
% isMICRO(1).epsilon_Macro0=FACT*[0.05; 0.05; 0; 0; 0]; % Modo04  ne25
% isMICRO(1).epsilon_Macro0=FACT*[0.07; 0; 0; 0.1; 0]; % Modo05  ne16
% isMICRO(1).epsilon_Macro0=FACT*[0.05; -0.05; 0; 0.15; 0]; % Modo06 ne16
% isMICRO(1).epsilon_Macro0=FACT*[-0.1; 0.05; 0; 0; 0.0]; % Modo07 ne15
% isMICRO(1).epsilon_Macro0=FACT*[-0.1; 0; 0; 0.2; 0.0]; % Modo08 ne9

% isMICRO(1).epsilon_Macro0=FACT*[0.07; 0; 0; 0; 0]; % Modo01  
% isMICRO(1).epsilon_Macro0=FACT*[0; 0.07; 0; 0; 0]; % Modo02 
% isMICRO(1).epsilon_Macro0=FACT*[0; 0; 0; 0.25; 0]; % Modo03 
% isMICRO(1).epsilon_Macro0=FACT*[0.05; 0.05; 0; 0; 0]; % Modo04 
% isMICRO(1).epsilon_Macro0=FACT*[0.07; 0; 0; 0.1; 0]; % Modo05
% isMICRO(1).epsilon_Macro0=FACT*[-0.2; 0; 0; 0; 0]; % Modo06 
% isMICRO(1).epsilon_Macro0=FACT*[-0.1; 0.05; 0; 0; 0.0]; % Modo07
% isMICRO(1).epsilon_Macro0=FACT*[-0.1; 0; 0; 0.2; 0.0]; % Modo08
% isMICRO(1).epsilon_Macro0=FACT*[-0.1; 0.1; 0; 0.3; 0]; % Modo09
% isMICRO(1).epsilon_Macro0=FACT*[-0.1; 0.1; 0; -0.2; 0]; % Modo10
% isMICRO(1).epsilon_Macro0=FACT*[0; 0.05; 0; -0.1; 0]; % Modo11
% isMICRO(1).epsilon_Macro0=FACT*[0; 0; 0; -0.3; 0]; % Modo12
% isMICRO(1).epsilon_Macro0=FACT*[0.05; 0.05; 0; -0.3; 0]; % Modo13
% isMICRO(1).epsilon_Macro0=FACT*[0.05; 0.05; 0; 0.1; 0]; % Modo14
% isMICRO(1).epsilon_Macro0=FACT*[0.04; 0; 0; -0.2; 0]; % Modo15
% isMICRO(1).epsilon_Macro0=FACT*[-0.05; 0; 0; -0.3; 0]; % Modo16 
% isMICRO(1).epsilon_Macro0=FACT*[0.07; 0; 0; 0.1; 0]; % Modo17
% isMICRO(1).epsilon_Macro0=FACT*[0; -0.12; 0; 0; 0]; % Modo18 
% isMICRO(1).epsilon_Macro0=FACT*[0; -0.12; 0; 0.2; 0]; % Modo19
% isMICRO(1).epsilon_Macro0=FACT*[0; -0.12; 0; -0.2; 0]; % Modo20
% isMICRO(1).epsilon_Macro0=FACT*[0.15; -0.15; 0; 0; 0]; % Modo21
% isMICRO(1).epsilon_Macro0=FACT*[0.15; -0.15; 0; 0.2; 0]; % Modo22
% isMICRO(1).epsilon_Macro0=FACT*[0.12; -0.12; 0; -0.2; 0]; % Modo23
% isMICRO(1).epsilon_Macro0=FACT*[-0.12; -0.12; 0; 0; 0]; % Modo24
% isMICRO(1).epsilon_Macro0=FACT*[-0.1; -0.1; 0; 0.2; 0]; % Modo25
% isMICRO(1).epsilon_Macro0=FACT*[0.1; -0.1; 0; -0.2; 0]; % Modo26
%% TEST 13 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% isMICRO(1).epsilon_Macro0=FACT*[2.5; 0; 0; 0; 0]; % Modo01   ne10
% isMICRO(1).epsilon_Macro0=FACT*[0; -0.5; 0; 0; 0]; % Modo02    ne22
% isMICRO(1).epsilon_Macro0=FACT*[0; 0; 0; 2; 0]; % Modo03    ne8
% isMICRO(1).epsilon_Macro0=FACT*[0; 0; 0; 0; -2]; % Modo04    ne8
% isMICRO(1).epsilon_Macro0=FACT*[2.5; 2.5; 0; 0; 0]; % Modo05    ne10
% isMICRO(1).epsilon_Macro0=FACT*[1; 0; 0; 1; 0]; % Modo06  ne16
% isMICRO(1).epsilon_Macro0=FACT*[0; -0.7; 0; 0.5; 0]; % Modo07 ne14
% isMICRO(1).epsilon_Macro0=FACT*[1; -0.5; 0; 0.4; 0]; % Modo08 ne13
% isMICRO(1).epsilon_Macro0=FACT*[-0.5; 0.8; 0; 0; 0.3]; % TRAYECTORIA NO ENTRENADA
%% REV_Laminate_01 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% isMICRO(1).epsilon_Macro0=FACT*[0.80; 0; 0; 0; 0]; % Modo01
% isMICRO(1).epsilon_Macro0=FACT*[0; 0.75; 0; 0; 0]; % Modo02 NO PLASTIFICA
% isMICRO(1).epsilon_Macro0=FACT*[0; 0; 0; 0; 1]; % Modo03 
% isMICRO(1).epsilon_Macro0=FACT*[0.7; -0.2; 0; 0; 0]; % Modo04
% isMICRO(1).epsilon_Macro0=FACT*[0.8; 0; 0; 1; 0]; % Modo05
% isMICRO(1).epsilon_Macro0=FACT*[0; 0.8; 0; 1; 0]; % Modo06
% isMICRO(1).epsilon_Macro0=FACT*[-0.5; 0.5; 0; 0; 0]; % Modo07
% isMICRO(1).epsilon_Macro0=FACT*[0.8; 0.8; 0; 1; 0]; % Modo08
% isMICRO(1).epsilon_Macro0=FACT*[0.8; -0.8; 0; 1; 1]; % Modo09
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Snapshots que se desean calcular
SnapStrain       = true;
SnapStress       = true;
SnapWeight       = true;
SnapEnergy_e     = true;
SnapEnergy_e_vol = true;
SnapEnergy_e_dev = true;
SnapEnergy_p     = true;
SnapEnergy_t     = true;
Snapflag         = true;

Snaps=[SnapStrain SnapStress SnapWeight SnapEnergy_e SnapEnergy_e_vol ...
    SnapEnergy_e_dev SnapEnergy_p SnapEnergy_t Snapflag];

for iTEST = 1:length(TEST_DATA)
%   try
        analysis(TEST_DATA(iTEST).path_file,TEST_DATA(iTEST).file,TEST_DATA(iTEST).nLab,isMICRO,Snaps);
%        matlabpool close
%   catch
%       warning('El proceso ha parado su ejecucion por falta de convergencia!');
%       matlabpool close
%   end
%
end

