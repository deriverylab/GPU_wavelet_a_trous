macro "Wavelet a trous filter" {

// Matlab implementation of the Wavelet a trous filter using a gaussian as a wavelet
// implemented in the Improve Kymo plugin writen by Fabrice Cordeliere
// https://github.com/fabricecordelieres/IJ_KymoToolBox/
// This code is parallelized (probably can be GPU accelerated as well)
// Copyright 2009-2018 by Emmanuel derivery @deriverylab
// v1.1 added GPU support


//--------Installation--------
// 1)install the matlab runtimes  MCR_R2015b_win64_installer.exe and MCR_R2017a_win64_installer.exe
// 2) install CUDA from Nvidia website if you want to use the GPU accelerated version
// 3) copy waveletatrous.exe into your Fiji\Plugin directory
// 4) open the image to filter and launch the macro wavelet a trous.ijm
// default parameters are good for diffraction-limited objects.

path=getDirectory("plugins");
getDimensions(totwidth, totheight, nC, nZ, nT); 
dir=getDirectory("image");
name=getTitle();
Compilerarray=newArray("monoCPU","multiCPU","GPU");


// initialization of parameters
k1=1;
k2=8;
Av=1;
Par=1;
worker=0;

Dialog.create("Wavelet à trous filter");
Dialog.addMessage("This code filters the image with a Wavelet a trous (aka discrete) transform using a gaussian as wavelet");
Dialog.addMessage(" ");
Dialog.addMessage("The original image is first copied n times. Each copy is convolved by a gaussian kernel of radius n pixels");
Dialog.addMessage(" The difference between two successive images is then computed in order to generate a wavelet plane");
Dialog.addMessage(" Several successive wavelet planes are then summed to produce the filtered image");
Dialog.addMessage(" ");
Dialog.addMessage("Succesive wavelet planes to keep");
Dialog.addNumber("first wavelet plane",k1 );
Dialog.addNumber("last wavelet plane",k2 );
Dialog.addCheckbox("Average output with source data ? ", Av);
Dialog.addMessage("Processing");
Dialog.addChoice(" What kind of computation ?", Compilerarray);
Dialog.addNumber("Number of cores to use if multi-CPU 0 [for auto]",worker);

Dialog.show();
k1=Dialog.getNumber();
k2=Dialog.getNumber();
Av = Dialog.getCheckbox();
Compiler=Dialog.getChoice();
worker=Dialog.getNumber();



if (Compiler=="monoCPU"){
	Par=0;
}else if (Compiler=="multiCPU") {
	Par=1;
}else if (Compiler=="GPU"){
	Par=2;
}

//----- Make the parameter string-----
//1) path input
//2) path ouput
//3) k1
//4) k2
//5) Av
//6) Par
//7) workers
//8) nC
//9) nZ
//10) nT


print(path+"Wavelet_filter.exe "+'"'+dir+name+"%%%%"+dir+name+"_wavelet.tif%%%%"+k1+"%%%%"+k2+"%%%%"+Av+"%%%%"+Par+"%%%%"+worker+"%%%%"+nC+"%%%%"+nZ+"%%%%"+nT+"%%%%"+'"');
exec(path+"Wavelet_filter.exe "+'"'+dir+name+"%%%%"+dir+name+"_wavelet.tif%%%%"+k1+"%%%%"+k2+"%%%%"+Av+"%%%%"+Par+"%%%%"+worker+"%%%%"+nC+"%%%%"+nZ+"%%%%"+nT+"%%%%"+'"');

open(dir+name+"_wavelet.tif");

}
