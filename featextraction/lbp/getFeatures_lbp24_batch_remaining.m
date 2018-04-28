function getFeaturesBatch(method, pathToDataset, pathToFeatures, categ, bound1,bound2)

pathToDataset=strcat(pathToDataset,categ,'/');
pathToFeatures=strcat(pathToFeatures,categ,'/');

if ( ~exist(pathToFeatures,'dir')); 
    disp(strcat('Creating ', pathToFeatures)); 
    mkdir (pathToFeatures);
end;

files=dir(pathToDataset);
files=files(3:end);

if nargin<5
    bound1=1;bound2=length(files);
end

paths={pathToDataset, pathToFeatures};
for i=1:2
    if (~exist(paths{i},'dir') )
        disp(strcat('Non existent folder ',paths{i}));
    end
end


%Go backwards if bound2>bound1
if bound1>bound2;  step=-1; else  step=1; end;


switch method
    case 'lyu'
        funHandle=@getFeatures_lyu;
    case 'lyuUnser'
        funHandle=@getFeatures_lyuUnser;
    case 'li'
        funHandle=@getFeatures_li;
    case 'glcm'
        funHandle=@getFeatures_glcmPyram;
    case 'hsc'
        funHandle=@getFeatures_hsc;
    case 'lsb'
        funHandle=@getFeatures_lsb;               
    case 'contourlets'
        funHandle=@getFeatures_contourlets;
    case 'contourlets12'
        funHandle=@getFeatures_contourlets12;
    case 'curvelets'
        funHandle=@getFeatures_curvelets;
    case 'sobel1'
        funHandle=@getFeatures_sobel1;
    case 'sobel2'
        funHandle=@getFeatures_sobel2;
    case 'sobel3'
        funHandle=@getFeatures_sobel3;
    case 'sobel4'
        funHandle=@getFeatures_sobel4;
    case 'LoG'
        funHandle=@getFeatures_LoG;        
    case 'boxCount'
        funHandle=@getFeatures_boxCount;
    case 'lbp24'
        funHandle=@getFeatures_lbp24;
    case 'lukas'
        funHandle=@getCFA;
    case 'shearlets'
        funHandle=@getFeatures_shearlets;
    case 'shearlets_tmp'
        funHandle=@getFeatures_shearlets_tmp;
    case 'shearlets_daubechies8'
        funHandle=@getFeatures_shearlets_daubechies8;
    case 'shearlets_daubechies16'
        funHandle=@getFeatures_shearlets_daubechies16;
    case 'shearlets_symmlet4_filtro33344'
        funHandle=@getFeatures_shearlets_symmlet4_filtro33344;
    case 'shearlets_Vaidyanathan'
        funHandle=@getFeatures_shearlets_Vaidyanathan;
    case 'popescu'
        funHandle=@getFeatures_popescu;
        
    otherwise
        disp ('Invalid Method');
        return;
end


for i=bound1:step:bound2
    if (~isempty(regexpi(files(i).name,'jpg'))  || ~isempty(regexpi(files(i).name,'png')))
        disp([int2str(i) ' : ' files(i).name]);
        featuresFileName=strcat (pathToFeatures,files(i).name,'_f'); 
        if(exist(featuresFileName,'file')~=0); continue; end; %Check existent file
        features=funHandle(strcat(pathToDataset,'/',files(i).name));
        if (length(features)==1); continue; end; %Function gonna return just '-1' in case of problems
        fh=fopen(featuresFileName,'w'); % The variable 'features' is a linearized matrix (i.e., is an array)
        fprintf(fh, '%f\t', features);
        fprintf(fh, '\n');
        fclose(fh);
    end;        
end

