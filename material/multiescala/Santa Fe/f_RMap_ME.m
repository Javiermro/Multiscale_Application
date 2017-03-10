function [m_CTHomog,sigmaHomog,hvar_newMacro] = f_RMap_ME(...
   eps_new,hvar_oldMacro,e_DatMatSetMacro,e_VGMacro)

   %Se recupera variables micro
   xx = e_DatMatSetMacro.xx;
   omegaMicro = e_DatMatSetMacro.omegaMicro;
   e_DatSet = e_DatMatSetMacro.e_DatSet;
   e_VG = e_DatMatSetMacro.e_VG;
   esImplexMacro = e_DatMatSetMacro.esImplex;
   e_VarEst_old = hvar_oldMacro.e_VarEst;
   u = hvar_oldMacro.u;
   c_GdlCond = hvar_oldMacro.c_GdlCond;
   Fint         = hvar_oldMacro.Fint;
   m_LinCond    = hvar_oldMacro.m_LinCond;
   doff         = hvar_oldMacro.doff;
   dofl         = hvar_oldMacro.dofl;
   %c_DefMacro   = hvar_oldMacro.c_DefMacro;

   %vfix = hvar_oldMacro.vfix;
   e_VarAux = hvar_oldMacro.e_VarAux;

   % VARIABLES GLOBALES
   nElemTot = e_VG.nElem;
   ntens = e_VG.ntens;
   ndoft = e_VG.ndoft;

   % INICIALIZACION DE VARIABLES
   Du_step_old = zeros(ndoft,1);  % Vector de incrementos de desplazamientos en el paso de tiempo previo
   Fext = zeros(ndoft,1);
   
   %Por si es necesario el paso tiempo a nivel micro.
   e_VG.istep = e_VGMacro.istep;
   %Se guarda que se quiere que el modelo constitutivo se comporte elásticamente.
   e_VG.elast = e_VGMacro.elast;
   %Para impresión y debug se guarda la iteración macro.
   e_VG.iterMacro = e_VGMacro.iter;
   %Para imprensión se guarda el número de elemento macro y número de PG macro.
   e_VG.iElemNumMacro = e_VGMacro.iElemNum;
   e_VG.iPGMacro = e_VGMacro.iPG;
   %
   e_VG.SharedFS = e_VGMacro.SharedFS;
   
   %Nombre interno de la celda unitaria 
   %(hacer esto en cada iteración puede ser medio lento, ver que hacer sino).
   %e_VG.fileCompleto = [e_VG.fileCompleto,'_EM',int2str(e_VGMacro.iElemNum),'PGM',int2str(e_VGMacro.iPG)];
   %Se guarda los datos del matlabpool (se utiliza para imprimir de pasos y iteraciones a nivel micro que no
   %convergieron).
   e_VG.nLab = e_VGMacro.nLab;
   e_VG.tipoMPool = e_VGMacro.tipoMPool;

   % DESPLAZAMIENTO IMPUESTO
   %No sería necesario estas operaciones porque vfix en todos los modelos clásicos de las
   %formulaciones multiescala son nulos. Además que habría que interpretar como realizar el delta
   %psi_value a nivel micro, ya debería se corresponder con el incremento de tiempo a nivel macro,
   %pero lo que implicaría que en cada paso de tiempo se esté resolviendo un RVE distinto.
   %vDeltaFixTemp = vfix;
   %vDeltaFixTemp(doffCondCte) = vfix(doffCondCte)*(psi_value - psi_value_old);
   %u(doff) = u(doff) + m_InvCRR*vDeltaFixTemp(doff);
  
   % Deformación macro aplicada en la Celda unitaria.
   %Se aplica en forma uniforme en todo dominio.
   %Por simplificidad se considera una deformación macro aplicada distinta por elemento, y no por PG.
   %(no es necesario considerar una estructura para esta variable).
   %m_DefMacro = repmat(eps_new,1,nElem);
   %Deformación macro por elemento y por punto de gauss, dividida en sets.
   %c_DefMacro = arrayfun(@(x)repmat(eps_new,[1,x.e_DatElem.npg,x.nElem]),e_DatSet,'UniformOutput',false);
   %Deformación macro por elemento, dividad en sets.
   c_DefMacro = arrayfun(@(x)repmat(eps_new,[1,x.nElem]),e_DatSet,'UniformOutput',false);
   
   %ticIDNewt = tic;
   % ESQUEMA DE NEWTON-RAPHSON
   Du_step_new = zeros(ndoft,1);
   [u,c_GdlCond,Fint,e_VarEst_new,e_VarAux,Du_step_new,c_CT,KT] = newton_raphson(...
      xx,m_LinCond,dofl,doff,u,Du_step_new,c_GdlCond,Du_step_old,Fint,Fext,e_VarEst_old,e_VarAux,e_DatSet,...
      c_DefMacro,e_VG);
  
   %Se guarda las fuerzas internas sólo para impresión de las gráficas X-Y
   %Se está usando equilibrio en totales, por lo que no es necesario la siguiente línea.
   %Fint = Fint+DFint;
   %
   %fprintf('Tiempo del Newton micro: %f\n',toc(ticIDNewt));   
   
   % TENSOR TANGENTE HOMOGENEIZADO
   m_CTHomog = f_ModTangHomog(KT,c_CT,m_LinCond,dofl,doff,e_DatSet,omegaMicro,...
        true(nElemTot,1),true(nElemTot,1),e_VG);
   
   %Se asume que no se realiza análisis de bifurcación con el tensor tangente constitutivo homogeneizado, por
   %lo que en el caso ser implex, se devuelve nulo el tensor implícito homogeneizado.
   if esImplexMacro
      m_CTHomog = struct('Implex',m_CTHomog,'Impli',zeros(ntens,ntens));
   end
   
   % CÁLCULO DE VARIABLES HOMOGENEIZADAS
   sigmaHomog = f_HomogArea({e_VarEst_new.sigma},ntens,omegaMicro,{e_DatSet.m_DetJT},e_DatSet,e_VG);
   %defHomog = f_HomogArea({e_VarEst_new.eps},ntens,omegaMicro,{e_DatSet.m_DetJT},e_DatSet,e_VG);
   defHomogFl = f_HomogArea({e_VarEst_new.eps_fluct},ntens,omegaMicro,{e_DatSet.m_DetJT},e_DatSet,e_VG);
   %Verificación de la media del desplazamiento
   m_uMedioFl = f_MediaDespCU(u,omegaMicro,e_DatSet,e_VG);
   %
   fprintf('Elemento %d: PG %d: Norma de la deformación fluctuante media: %g\n',e_VGMacro.iElemNum,...
      e_VGMacro.iPG,norm(defHomogFl))
   fprintf('Elemento %d: PG %d: Norma del desplazamiento fluctuante medio: %g\n',e_VGMacro.iElemNum,...
      e_VGMacro.iPG,norm(m_uMedioFl))
   
   hvar_newMacro = struct('u',u,'c_GdlCond',{c_GdlCond},'Fint',Fint,'e_VarEst',e_VarEst_new,...
      'e_VarAux',e_VarAux,'m_LinCond',m_LinCond,'doff',doff,'dofl',dofl,'c_DefMacro',{c_DefMacro});
   
end
