function [] = Wavelet_filter(string)


warning('off','MATLAB:imagesci:tiffmexutils:libtiffWarning');
warning('off', 'imageio:tiffmexutils:libtiffWarning');

%----------------description--------------
%Fiji wrapper for the matlab implementation of the wavelet filter

%instructions, for windows (change if other OS):
% i) compile this file
% ii) call it Wavelet_filter.exe 
% iii) put it in your Fiji plugin folder
% iii) launch the macro wavelet a trous.ijm in Fiji
%----------------------------------------------


%main code
%import data from imageJ/Fiji
% //----- syntax the parameter string-----

%inputfile    inputstack (can be >4GB)
%outputfile   ouputstack (bigtiff)
%wavelet_k1  first kernel kept
%wavelet_k2    last kernel kept
%wavelet_Av  if set to 1, filtered image will be averaged with raw image
%wavelet_Par    Par=0: single core Par=1 multicore   Par=2 GPU
%wavelet_worker  number of core to use (put 0 for max)
%nC dimensions of hyperstack
%nZ dimensions of hyperstack
%nT dimensions of hyperstack

string = split(string,"%%%%");
inputfile=char(string(1,1));
outputfile=char(string(2,1));
wavelet_k1=str2num(char(string(3,1)));
wavelet_k2=str2num(char(string(4,1)));
wavelet_Av=str2num(char(string(5,1)));
wavelet_Par=str2num(char(string(6,1)));
wavelet_worker=str2num(char(string(7,1)));
nC=str2num(char(string(8,1)));
nZ=str2num(char(string(9,1)));
nT=str2num(char(string(10,1)));

Wavelet_filter_func(inputfile,outputfile,wavelet_k1,wavelet_k2,wavelet_Av,wavelet_worker,wavelet_Par,nC,nZ,nT);
end