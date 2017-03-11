function f_InicArchDat(in,m_SetElem,e_DatSet,e_VG)

   nSet = e_VG.nSet;
   fileCompleto = e_VG.fileCompleto;
   
   %% Archivo que indica que paso del esquema del newton que no convergi�.
   nomArch = [fileCompleto,'.pasNoConv'];
   %Se borra para que cuando no converja se cree el archivo y indique que no convergi� alg�n paso.
   %Por ahora no se crea estos archivos para el problema multiescala, ya que si son mucho los elementos de
   %este tipo genera muchos archivos que hacen lento el directorio y tarda mucho. Tambi�n va ser un problema
   %en el caso de que se use en un cluster y no encuentre el archivo donde escribir.
%    if ~e_VG.esME
%       fId = fopen(nomArch,'wt');
%       fprintf(fId,'#Pasos en que el esquema de newton no convergi�.\n');
%       fclose(fId);
%    end
   %Para que el caso multiescala se imprima un solo archivo de pasos de tiempo para todos los PG macro, se
   %se usa un nombre �nico.
   if e_VG.esME
      nomArch = [e_VG.fileCompletoOrig,'.pasNoConv'];
   end
   fId = fopen(nomArch,'wt');
   fprintf(fId,'#Pasos en que el esquema de newton no convergi�.\n');
   fclose(fId);
   
   %% Archivos seg�n el elemento y el modelo constitutivo
   for iSet = 1:nSet
      
      e_DatElemSet = e_DatSet(iSet).e_DatElem;
      e_DatMatSet = e_DatSet(iSet).e_DatMat;
      m_NumElem = e_DatSet(iSet).m_NumElem;      
      nElem = e_DatSet(iSet).nElem;
      npg = e_DatElemSet.npg;
            
      for iElem = 1:nElem
         
         eltype = e_DatElemSet.eltype;
         conshyp = e_DatMatSet.conshyp;
      
         for iPG = 1:npg
            
            %Seg�n el tipo de elemento se inicializa los archivos de an�lisis de bifurcaci�n.
            switch eltype
               case {2,4,10,22,23,108}  % Tri�ngulo de 3 nodos con discontinuidades fuertes (SDA)
                  if iPG==1
                     %An�lisis de bifurcaci�n
                     %Se asume que este elemento tiene dos puntos de gauss, en la misma
                     %posici�n, por lo que se imprime el an�lisis de bifurcaci�n del punto regular.
%                      nombrArchBif = [fileCompleto,'_E',int2str(m_NumElem(iElem)),'.analisisBif']; 
%                      fId = fopen(nombrArchBif,'wt');
%                      fprintf(fId,'#An�lisis de bifurcaci�n.\n');
%                      fclose(fId);
                  end
                  %Para tener un solo archivo para el todo set.
                  if iElem==1&&iPG==1
                     %An�lisis de bifurcaci�n
                     %Este se asume que este elemento tiene dos puntos de gauss, en la misma
                     %posici�n, por lo que se imprime el an�lisis de bifurcaci�n del punto regular.
                     %Notar que si se tiene varios sets con el mismo modelo constitutivo se utiliza
                     %el mismo archivo (ver si no cambiar el nombre por set)
                     nomArch = [fileCompleto,'.elemBif'];
                     fId = fopen(nomArch,'wt');
                     fprintf(fId,'#Elementos que bifurcaron y paso que lo hicieron.\n');
                     fprintf(fId,['#| Paso (tiempo) | Elemento | �ngulos de la normal ',...
                        'usado (�ngulos del an�lisis de bifurcaci�n)\n']);
                     fclose(fId);
                  end
            end
            
            %Seg�n el tipo modelo constitutivo se inicializa los archivos de datos
            switch conshyp
               case {50,51} %Modelo multiescala cl�sico y cohesivo
                  e_VGMicro = e_DatMatSet.e_VG;
                  e_VGMicro.fileCompletoOrig = e_VGMicro.fileCompleto;
                  e_VGMicro.fileCompleto = [e_VGMicro.fileCompleto,'_EM',...
                     int2str(m_NumElem(iElem)),'PGM',int2str(iPG)];
                  e_VGMicro.esME = true;
                  f_InicArchDat(e_DatMatSet.in,e_DatMatSet.m_SetElem,e_DatMatSet.e_DatSet,e_VGMicro)
                  %Se imprime el an�lisis de bifurcaci�n para el punto de gauss regular.
                  if (eltype==10 ||eltype==22||eltype==23) &&iPG==1&&any(e_DatMatSet.m_ElemPGImpr(...
                        1,e_DatMatSet.m_ElemPGImpr(2,:)==iPG)==iElem)
                     %An�lisis de bifurcaci�n
                     nombrArchBif = [fileCompleto,'_E',int2str(m_NumElem(iElem)),'.analisisBif']; 
                     fId = fopen(nombrArchBif,'wt');
                     fprintf(fId,'#An�lisis de bifurcaci�n.\n');
                     fclose(fId);
                  end
            end
            
         end
      
      end
      
   end
   
   %% Inicializaci�n del del archivo de datos y impresi�n del encabezado
%    c_NomDat = {'T','Dx','Dy','Dz','Fx','Fy','Fz','Bx','By','Bz','Tx','Ty','Tz',...
%       'Exx','Eyy','Ezz','Exy','Eyx','Txx','Tyy','Tzz','Txy','Tyx','Efxx','Efyy','Efzz','Efxy',...
%       'Da'};
   c_NomDat = {'T','Dx','Dy','Dz','Fx','Fy','Fz','Bx','By','Bz','Tx','Ty','Tz',...
      'Exx','Eyy','Ezz','Exy','Eyx','Txx','Tyy','Tzz','Txy','Tyx','Efxx','Efyy','Efzz','Efxy',...
      'Da','DisGLO','Ehxx','Ehyy','Ehzz','Ehxy','Shxx','Shyy','Shzz','Shxy','Snn','Snt'}; %JLM

   c_TextTipoEjeGraf = {'X','Y'};

   %En m_DatGrafXY se tiene organizados los datos de la siguiente manera:
   %{'Nx','Ny','Ex','Ey','PGx','PGy','X','Y'}
   m_DatGrafXY = e_VG.m_DatGrafXY;      
      
   if ~isempty(m_DatGrafXY)
      nGraf = size(m_DatGrafXY,1);
      c_TextoEjes = cell(2,1);
      for iGraf = 1:nGraf         
         for iEje = 1:2
            tipoDat = c_NomDat{m_DatGrafXY(iGraf,iEje+6)};
            switch tipoDat
               case 'T'                     
                  c_TextoEjes{iEje} = 'Tiempo';
               case 'Dx'
                  nodo = in(m_DatGrafXY(iGraf,iEje));
                  f_VerifInfoGraf(nodo,'nodo',c_TextTipoEjeGraf{iEje},iGraf);
                  c_TextoEjes{iEje} = ['Componente X del desplazamiento del nodo ',int2str(nodo)];
               case 'Dy'
                  nodo = in(m_DatGrafXY(iGraf,iEje));
                  f_VerifInfoGraf(nodo,'nodo',c_TextTipoEjeGraf{iEje},iGraf);
                  c_TextoEjes{iEje} = ['Componente Y del desplazamiento del nodo ',int2str(nodo)];
               case 'Fx'
                  nodo = in(m_DatGrafXY(iGraf,iEje));
                  f_VerifInfoGraf(nodo,'nodo',c_TextTipoEjeGraf{iEje},iGraf);
                  c_TextoEjes{iEje} = ['Componente X de la fuerza interna del nodo ',int2str(nodo)];
               case 'Fy'
                  nodo = in(m_DatGrafXY(iGraf,iEje));
                  f_VerifInfoGraf(nodo,'nodo',c_TextTipoEjeGraf{iEje},iGraf);
                  c_TextoEjes{iEje} = ['Componente Y de la fuerza interna del nodo ',int2str(nodo)];
               case 'Bx'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Componente X del salto del elemento ',int2str(elem)];
               case 'By'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Componente Y del salto del elemento ',int2str(elem)];
               case 'Tx'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Componente X de la tracci�n del elemento ',int2str(elem)];
               case 'Ty'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Componente Y de la tracci�n del elemento ',int2str(elem)];
               case 'Exx'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);                  
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Deformaci�n Exx del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'Eyy'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);                  
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Deformaci�n Eyy del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'Ezz'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);                  
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Deformaci�n Ezz del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'Exy'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);                  
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Deformaci�n Exy del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'Eyx'     %Para el caso de tensores no sim�tricos (LD por ejemplo)
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);                  
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Deformaci�n Eyx del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];       
               case 'Efxx'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);                  
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Deformaci�n fluctuante Exx del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'Efyy'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);                  
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Deformaci�n fluctuante Eyy del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'Efzz'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);                  
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Deformaci�n fluctuante Ezz del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'Efxy'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);                  
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Deformaci�n fluctuante Exy del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'Txx'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Tensi�n Txx del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'Tyy'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Tensi�n Tyy del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'Tzz'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Tensi�n Tzz del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'Txy'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Tensi�n Txy del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'Tyx'     %Para el caso de tensores no sim�tricos (LD por ejemplo)
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Tensi�n Tyx del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'Da'
                  elem = m_DatGrafXY(iGraf,iEje+2);
                  f_VerifInfoGraf(elem,'elemento',c_TextTipoEjeGraf{iEje},iGraf);
                  pg = m_DatGrafXY(iGraf,iEje+4);
                  f_VerifInfoGraf(pg,'punto de gauss',c_TextTipoEjeGraf{iEje},iGraf);
                  set = m_SetElem(elem);
                  elem = e_DatSet(set).m_NumElem(e_DatSet(set).m_IndElemSet==elem);
                  c_TextoEjes{iEje} = ['Variable de da�o del elemento ',int2str(elem),...
                     ' y del punto de gauss ',int2str(pg)];
               case 'DisGLO'
                  c_TextoEjes{iEje} = ['Disipacion estructural del test'];
                case 'Ehxx'
                  c_TextoEjes{iEje} = ['Homogenized Strain (component xx)'];
                case 'Ehyy'
                    c_TextoEjes{iEje} = ['Homogenized Strain (component yy)'];
                case 'Ehzz'
                    c_TextoEjes{iEje} = ['Homogenized Strain (component zz)'];
                case 'Ehxy'
                    c_TextoEjes{iEje} = ['Homogenized Strain (component xy)'];
                case 'Shxx'
                    c_TextoEjes{iEje} = ['Homogenized Stress (component xx)'];
                case 'Shyy'
                    c_TextoEjes{iEje} = ['Homogenized Stress (component yy)'];
                case 'Shzz'
                    c_TextoEjes{iEje} = ['Homogenized Stress (component zz)'];
                case 'Shxy'
                    c_TextoEjes{iEje} = ['Homogenized Stress (component xy)'];
                case 'Snn'
                    c_TextoEjes{iEje} = ['Homogenized Stress (component nn)'];
                case 'Snt'
                    c_TextoEjes{iEje} = ['Homogenized Stress (component nt)'];
               otherwise
                  error('Archivos de datos: Inicializaci�n: No est� definido este tipo de dato.')
            end
         end
         fId = fopen([fileCompleto,'.cur',num2str(iGraf,'%03d')],'wt');
         %Se usa el s�mbolo de comentario est�ndar del GNUPlot
         fprintf(fId,['#',c_TextoEjes{1},' Vs ',c_TextoEjes{2},'\n']);
         fclose(fId);            
      end         
   end

end

function f_VerifInfoGraf(ubic,textTipoUbic,textTipoEje,iGraf)
   
   if isnan(ubic)
      error(['Archivos de datos: Inicializaci�n: Se debe ingresar el n�mero ',...
         'de %s para los datos del eje %s de la gr�fica %d.'],textTipoUbic,textTipoEje,iGraf)
   end
   
end