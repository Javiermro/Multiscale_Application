function u = nonlinear_analysis(in,xx,m_SetElem,f,funbc,e_DatSet,e_VG)

%***************************************,***************************************************
%*  RUTINA PARA RESOLVER EL PROBLEMA NO LINEAL MATERIAL MEDIANTE M.E.F.                   *
%*                                                                                        *
%*  ARGUMENTOS DE ENTRADA:                                                                *
%*  file    : nombre del archivo de datos para el problema en estudio                     *
%*  in     : lista de nodos                                                               *
%*  xx      : lista de coordenadas                                                        *
%*  conec   : lista de conectividades                                                     *
%*  vfix    : vector de desplazamientos impuestos                                         *
%*  f       : vector de cargas externas aplicadas                                         *
%*  funbc   : funcion temporal para aplicar condiciones de borde                          *
%*  Eprop   : lista de propiedades de los elementos                                       *
%*                                                                                        *
%*  ARGUMENTOS DE SALIDA:                                                                 *
%*  u       : vector de desplazamientos                                                   *
%*                                                                                        *
%*  A.E. Huespe, P.J.Sanchez                                                              *
%*  CIMEC-INTEC-UNL-CONICET                                                               *
%******************************************************************************************

% VARIABLES GLOBALES
struhyp = e_VG.struhyp;
ndoft              = e_VG.ndoft;
nElem              = e_VG.nElem;
ndn = e_VG.ndn;
np                 = e_VG.np;
postpro_impre_step = e_VG.postpro_impre_step;
CONTROL_STRAT      = e_VG.CONTROL_STRAT;
Dtime              = e_VG.Dtime;
ndime              = e_VG.ndime;
ntens              = e_VG.ntens;
nSet = e_VG.nSet;

% INICIALIZACION DE VARIABLES
Fint            = zeros(ndoft,1);             % Vector de fzas internas
Fext            = zeros(ndoft,1);             % Vector de fzas internas
u               = zeros(ndoft,1);             % Vector de desplazamientos totales
Du_step_old     = zeros(ndoft,1);             % Vector de incrementos de desplazamientos en el paso de tiempo previo
%hvar_old        = zeros(sihvare,nElem);       % Vector de variables internas del paso previo
%eps_old         = zeros(sitvare,nElem);       % Vector de deformaciones previas
%sigma_old       = zeros(sitvare,nElem);       % Vector de tensiones previas
%Por simplicidad se considera una deformaci�n macro aplicada distinta por elemento, y no por PG.
%(no es necesario considerar una estructura para esta variable)
%DefMacro = zeros(ntens*npg,nElem);
%DefMacro = zeros(ntens,nElem);
sigmaHomog      = zeros(ntens,1);

if e_VG.isMICRO.MICRO
    switch struhyp %e_VG.conshyp
        case 20 %{100,110} % No linealidad geometrica Elastic Material neo-Hookean y J2, It is assumed next order Voigt tensor [Fxx;Fyy;Fzz;Fxy;Fyx]
            epsilon_Macro  = [1; 1; 1; 0; 0;];
            epsilon_Macro0 = e_VG.isMICRO.epsilon_Macro0 ;% +epsilon_Macro ;% % Increment of macro-strain
        otherwise % Peque�as deformaciones
            epsilon_Macro  = zeros(ntens,1); % Initial imposed macro-strain
            epsilon_Macro0 = e_VG.isMICRO.epsilon_Macro0 ; % Increment of macro-strain
    end 
else
    epsilon_Macro  = zeros(ntens,1); %JLM
end

%% Iniciacion Matriz de Snapshots (JLM)
if e_VG.isMICRO.MICRO && ~isempty(e_VG.Snap)
    nglT = 0 ;
    nset = e_VG.nSet ;
    ntens= e_VG.ntens ;  
    for iset=1:nset
        nElemS = e_DatSet(iset).nElem ;
        npg    = e_DatSet(iset).e_DatElem.npg ;
        nglT   = nglT + nElemS*npg; %*ntens ;
    end
%     SnapStrain       = zeros(nglT*ntens,np) ;
%     SnapStress       = zeros(nglT*ntens,np) ;
%     SnapWeight       = zeros(1,np) ;
%     SnapEnergy_e     = zeros(nglT,np) ;
%     SnapEnergy_e_vol = zeros(nglT,np) ;
%     SnapEnergy_e_dev = zeros(nglT,np) ;
%     SnapEnergy_p     = zeros(nglT,np) ;
%     SnapEnergy_t     = zeros(nglT,np) ;
%     Snapflag         = zeros(1,np) ;
%% PointersToSet es el puntero hacia cada subdominio (REG o DIS).
%  Si hay mas Sets que subdominios hay que indicar a mano que set de EF
%  corresponde a cada subdominio (JLM)
    PointersToSet1 = true(nglT*ntens,1) ;
    PointersToSet2 = false(nglT*ntens,1) ;

    iSetDis = 2;
    % SOLO FUNCIONA CON 2 subdominios
    ind_elem_set = [] ;

    nElemS = e_DatSet(iSetDis).nElem ; % nElem = 4;
    npg = e_DatSet(iSetDis).e_DatElem.npg ;
    ElemSet = e_DatSet(iSetDis).m_IndElemSet ;

    for ielem=1:nElemS
        ind_elem_set = [ind_elem_set ;[(ElemSet(ielem)-1)*npg*ntens + [1:1:npg*ntens]]'];  % Mind=[Mind ;[(ElemSet(ielem)-1)*4 + [1:1:4]]'];  
    end
    PointersToSet1(ind_elem_set,1) = false ;
    PointersToSet2(ind_elem_set,1) = true ;

    save('DomainPointers.mat','PointersToSet1','PointersToSet2')
    clear ElemSet PointersToSet1 PointersToSet1

%     Estructura de datos para almacenar los snapshots
    Snapshots = struct('SnapStrain',[],'SnapStress',[],'SnapWeight',[],...
        'SnapEnergy_e',[],'SnapEnergy_e_vol',[],'SnapEnergy_e_dev',[],...
        'SnapEnergy_p',[],'SnapEnergy_t',[],'Snapflag',[]);
end


%%

% switch struhyp %JLM
%    case {1,2,3,4,5}
%       DefMacroT = zeros(ntens,nElem);
%       %DefMacro = arrayfun(@(x)zeros(e_VG.ntens,x.e_DatElem.npg,x.nElem),e_DatSet,'UniformOutput',false);
%       %DefMacro = zeros(ntens,nElem);
%       DefMacro = arrayfun(@(x)zeros(ntens,x.nElem),e_DatSet,'UniformOutput',false);
%    case 20
%       %It is assumed next order Voigt tensor [Fxx;Fyy;Fzz;Fxy;Fyx].
%       DefMacroT = zeros(ntens,nElem);
%       %DefMacro = [ones(ndime,nElem);zeros(ntens-ndime,nElem)];
%       DefMacro = arrayfun(@(x)[ones(3,x.nElem);zeros(ntens-3,x.nElem)],e_DatSet,...
%          'UniformOutput',false);
%    otherwise
%       error(['Nonlinear analysis: Macro information variables definition: ',...
%          'Structural Hypothesis has not been implemented.'])
% end
ELOCCalc = false(1,nElem);
%eps_fluct_old   = zeros(sitvare,nElem);       % Vector de deformaciones fluctuantes previas

e_VarEst_old = f_eVarEstInic({'sigma','eps','eps_fluct','hvar'},e_DatSet,e_VG);
%e_VarEst_new = e_VarEst_old;
%Se env�a xx solo para inicializar los matriz de deformaci�n del punto central del elemento FBar_LD.
e_VarAux = f_eVarAuxInic(xx,e_DatSet,e_VG);
c_GdlCond = f_cVarCondInic(e_DatSet,e_VG);

%Impresi�n de archivo de postprocesado de la malla y inicializaci�n del archivo de datos
matlab2gid_mesh(in,xx,e_DatSet,e_VG)
e_VG.istep = 0;
f_InicArchDat(in,m_SetElem,e_DatSet,e_VG)

%Ploteo en el paso 0 (se asume que tiene todos valores nulos en tiempo 0)
%Esto �ltimo habr�a que ver con las condiciones de borde y la funci�n psi_value (por ejemplo que esta no
%sea nula en el tiempo 0)
%sitvare = e_VG.sitvare;
%nnod    = e_VG.nnod;
%matlab2gid_res(0,u,zeros(sitvare,nElem),zeros(sitvare,nElem),zeros(sitvare,nElem),DefMacro,...
%   zeros(sihvare,nElem),e_VG,zeros(nnod,ntens),zeros(ndime,nnod));
f_SaveDatGraf(u,c_GdlCond,Fint,e_VarEst_old,e_VarAux,e_DatSet,m_SetElem,sigmaHomog,epsilon_Macro,e_VG) ; % JLM falta mandar sigmaHomog 

% VALOR DE LA FUNCI�N Psi EN EL TIEMPO CERO
psi_value_old      = get_psi_value(funbc,0,e_VG);
%Fext               = f*psi_value_old;

%Con istepSave se indica desde que paso se empieza a correr. Si lee el archivo mat, el valor nulo de
%istepSave es pisado por el paso donde se guard� el workspace.
istepSave = 0;
[dirFile,nomFile] = fileparts(e_VG.fileCompleto);
if 0
   %Hay algunas variables que tienen que recuperarse como vienen previamente al load del workspace, como el
   %path al archivo, ya que si se guarda en una computadora con directorios distintos a donde se hace el load
   %del workspace va tirar error posterior a la lectura. Adem�s estas variables que se utilizan su valor
   %previo no tiene cambiar durante la corrida del programa, ya que justamente no se recuperan.
   %IGUAL FALLA PORQUE HAY QUE CAMBIAR EL E_VGMicro.fileCompleto, tambi�n falla en el handle a un funci�n,
   %donde se guarda el path absoluto.
   %fileCompletoTemp = e_VG.fileCompleto;
   load(fullfile(dirFile,'PasoSalvado'))
   %e_VG.fileCompleto = fileCompletoTemp;
   fprintf('Se recupera los valores de las variables del paso %d.\n',istepSave)
end
%Se indica cada cuánto se salva los pasos
deltaPasoSave = 100;

% INFORMACION ADICIONAL
%Se lee un script de matlab. Esto permite cambiar algunas propiedades, matrices, etc., antes de entrar en el
%c�lculo en forma r�pida sin modificar demasiado el programa.
%Ocurre un error al usar usar run, no s� si pasa lo mismo con eval, ya que matlab no se da cuenta
%que un script o funci�n fue modificada para precompilarla (usa la precompilaci�n anterior). Esto
%hace que las modificaciones del script las ignora y usa por ejemplo valores de variable que son de
%la versi�n del script anterior.
%Esto se arregla con clear all, pero eso puede traer muchos problemas, adem�s que se desaprovecha
%las precompilaciones previas. Se borra solo la precompilaci�n de la funci�n (hay que usar el nombre
%de la funci�n solo, sin camino).
if exist([e_VG.fileCompleto,'.m'],'file')
   clear(nomFile)
   %run corre el script sin estar en el path o que en el directorio activo
   run([e_VG.fileCompleto,'.m'])
end

% FUNCI�N CONDICIONES DE BORDE
[m_LinCond,vfix,m_InvCRR,doff,dofl,doffCondCte] = f_CondBord(e_VG,xx,e_DatSet,e_VG.m_ConecFront);

% stepLimInf = 270;
% facdPsiv = 1;

% Medici�n de tiempos en un cluster mediante parTicToc
c_ParTT = cell(np,1);

% INTEGRACION TEMPORAL
for istep = istepSave+1:np
   
   ticStep = tic;
   
   e_VG.istep = istep;
   
   time = Dtime*istep;
   
   fprintf('STEP: %-3d\n',istep);
   
   % VALOR ACTUAL DE LA FUNCION TEMPORAL PARA ESCALAR CONDICIONES DE BORDE
   psi_value = get_psi_value(funbc,time,e_VG);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % epsilon_Macro = epsilon_Macro + epsilon_Macro0*(psi_value - psi_value_old);
   % DefMacro =arrayfun(@(x)repmat(epsilon_Macro,[1,x.e_DatElem.npg,x.nElem]),e_DatSet,'UniformOutput',false);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if e_VG.isMICRO.MICRO
        epsilon_Macro = epsilon_Macro + epsilon_Macro0*(psi_value - psi_value_old);
%         if e_VG.MOD_TYPE==2 % MONOSCALE + HROM
%             DefMacro =arrayfun(@(x)repmat(epsilon_Macro,[1,x.e_DatElem.npg,x.nElem]),e_VG.ROM_II.e_DatSet_ROM,'UniformOutput',false);
%         else % MONOSCALE + ROM & FE
            DefMacro =arrayfun(@(x)repmat(epsilon_Macro,[1,x.e_DatElem.npg,x.nElem]),e_DatSet,'UniformOutput',false);
%         end
        DefMacroT = epsilon_Macro;            
    else
        switch struhyp %e_VG.conshyp
            case 20 %{100,110} % No linealidad geometrica Elastic Material neo-Hookean y J2
                %It is assumed next order Voigt tensor [Fxx;Fyy;Fzz;Fxy;Fyx]
                DefMacroT = zeros(ntens,nElem);
                DefMacro = arrayfun(@(x)[ones(3,x.nElem);zeros(ntens-3,x.nElem)],e_DatSet,'UniformOutput',false);
%                     DefMacro = arrayfun(@(x)zeros(e_VG.ntens,x.e_DatElem.npg,x.nElem),e_DatSet,'UniformOutput',false);
%                     DefMacroT = zeros(ntens,1);
            otherwise % Peque�as deformaciones
                DefMacro = arrayfun(@(x)zeros(e_VG.ntens,x.e_DatElem.npg,x.nElem),e_DatSet,'UniformOutput',false);
                DefMacroT = zeros(ntens,1);
        end            
    end
    
       
    
    
    
    
%     if e_VG.isMICRO.MICRO
%         switch struhyp %e_VG.conshyp
%             case 20 %{100,110} % No linealidad geometrica Elastic Material neo-Hookean y J2
%                 %It is assumed next order Voigt tensor [Fxx;Fyy;Fzz;Fxy;Fyx]
%                 epsilon_Macro = epsilon_Macro + epsilon_Macro0*(psi_value - psi_value_old);
%                 [1 1 1 0 0]' + epsilon_Macro
%                 DefMacroT = zeros(ntens,nElem);
%                 DefMacro = arrayfun(@(x)[ones(3,x.nElem);zeros(ntens-3,x.nElem)],e_DatSet,'UniformOutput',false);
%             otherwise % Peque�as deformaciones
%                 epsilon_Macro = epsilon_Macro + epsilon_Macro0*(psi_value - psi_value_old);
%                 DefMacro =arrayfun(@(x)repmat(epsilon_Macro,[1,x.e_DatElem.npg,x.nElem]),e_DatSet,'UniformOutput',false);
%                 DefMacroT = epsilon_Macro;
%         end          
%             
%     else
%         switch struhyp %e_VG.conshyp
%             case 20 %{100,110} % No linealidad geometrica Elastic Material neo-Hookean y J2
%                 %It is assumed next order Voigt tensor [Fxx;Fyy;Fzz;Fxy;Fyx]
%                 DefMacroT = zeros(ntens,nElem);
%                 DefMacro = arrayfun(@(x)[ones(3,x.nElem);zeros(ntens-3,x.nElem)],e_DatSet,'UniformOutput',false);
% %                     DefMacro = arrayfun(@(x)zeros(e_VG.ntens,x.e_DatElem.npg,x.nElem),e_DatSet,'UniformOutput',false);
% %                     DefMacroT = zeros(ntens,1);
%             otherwise % Peque�as deformaciones
%                 DefMacro = arrayfun(@(x)zeros(e_VG.ntens,x.e_DatElem.npg,x.nElem),e_DatSet,'UniformOutput',false);
%                 DefMacroT = zeros(ntens,1);
%         end            
%     end
     
     
     
   % DESPLAZAMIENTO IMPUESTO
   vDeltaFixTemp = vfix;
   Du_step_new = zeros(ndoft,1);
   
   % FUERZA EXTERNA IMPUESTA
   if (CONTROL_STRAT == 1)
      Fext = f*psi_value;
      vDeltaFixTemp(doffCondCte) = vfix(doffCondCte)*(psi_value - psi_value_old);
      u(doff)                    = u(doff) + m_InvCRR*vDeltaFixTemp(doff);
      Du_step_new(doff)          = m_InvCRR*vDeltaFixTemp(doff);
   else
      Fext = f;
      e_VG.vfix                  =  vfix;
      e_VG.vfix_doff             =  m_InvCRR*vfix(doff);
      Du_step_new(doff)          =  e_VG.vfix_doff*e_VG.lambda - u(doff) ;
      u(doff)                    =  e_VG.vfix_doff*e_VG.lambda;
   end
   
   ticIDNewt = tic;
   % ESQUEMA DE NEWTON-RAPHSON
   [u,c_GdlCond,Fint,e_VarEst_new,e_VarAux,Du_step_new,c_CT,KT,lambda,o_Par] = newton_raphson(xx,m_LinCond,...
      dofl,doff,u,Du_step_new,c_GdlCond,Du_step_old,Fint,Fext,e_VarEst_old,e_VarAux,e_DatSet,DefMacro,e_VG);
   %Como dentro de las funciones que se llama a partir de newton_raphson, Fint representa el
   %incremento de las fuerzas internas, para impresi�n de los resultados se actualiza las fuerzas
   %internas.
   %Fint = Fint+DFint;
   %Fint_old = Fint_new;
   fprintf('Tiempo del Newton: %f\n',toc(ticIDNewt));
   c_ParTT{istep} = o_Par;
  
   % IMPRESI�N DE RESULTADOS
   index_print = rem(istep,e_VG.IRES);
   if (index_print == 0)
      if mod(istep,postpro_impre_step)==0
         % DESPLAZAMIENTO TOTAL DE LA MICRO-CELDA
         uTotal = [DefMacroT(1),DefMacroT(4)/2;DefMacroT(4)/2,DefMacroT(2)]*xx(:,1:2)'...
            +reshape(u,ndn,[]);
         matlab2gid_res(istep,in,u,c_GdlCond,e_DatSet,e_VarEst_new,e_VarAux,DefMacro,uTotal,...
            ELOCCalc,e_VG)
      end
   end
   
   Snapshots = SnapshotSave(Snapshots,istep,e_VarAux,e_VarEst_new,e_DatSet,e_VG,nglT) ;
   
   % Operaciones Constitutivas despu�s de la convergencia del Newton
   %Se coloca al final de todo, despu�s de la impresi�n de los resultados para que se imprima los
   %valores con los datos que se utilizaron para obtenerlos. Por ejemplo, que las tensiones que se
   %grafica se corresponde con la normal indicada, y no la que se podr�a obtener del an�lisis dentro
   %de f_OperConst.
   
   [e_DatSet,e_VarEst_new,e_VarAux,sigmaHomog,e_VG] = ...
      f_OperPosConv(u,xx,e_VarEst_new,e_VarEst_old,e_VarAux,e_DatSet,c_CT,KT,m_LinCond,dofl,doff,e_VG);

   % Almacenamiento de datos para gr�ficos X-Y
   f_SaveDatGraf(u,c_GdlCond,Fint,e_VarEst_new,e_VarAux,e_DatSet,m_SetElem,sigmaHomog,epsilon_Macro,e_VG) ;%JLM falta sigmaHomog
  
   % ACTUALIZACI�N DE VARIABLES
   psi_value_old      = psi_value;
   Du_step_old        = Du_step_new;
   e_VarEst_old       = e_VarEst_new;
   if (CONTROL_STRAT == 4)
      e_VG.lambda        = lambda;
   end
   
   if ~mod(istep,deltaPasoSave)
   %if istep==147e6
      istepSave = istep;
      save(fullfile(dirFile,'PasoSalvado'))
      %Para que soporte archivos de m�s de 1 Gb.
      %save(fullfile(dirFile,'PasoSalvado'),'-v7.3')
   end
   
   fprintf('FIN DE PASO: %-3d (tiempo: %f)\n',istep,toc(ticStep));
   disp('*******************************************************************')


end

%% Almacenamiento de las matrices de Snapshots
[dir,nomb] = fileparts(e_VG.fileCompleto);
   
save(['SNAPSHOTS_' nomb '.mat']  ,'-struct', 'Snapshots');







