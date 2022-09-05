# GPU_wavelet_a_trous (Wavelet_filter_func.m)
Performs Wavelet "a trous" filtering on a tif (hyper)stack

# Main file
inputfile    inputstack (can be >4GB)
outputfile   ouputstack (bigtiff)
wavelet_k1  first kernel kept
wavelet_k2    last kernel kept
wavelet_Av  if set to 1, filtered image will be averaged with raw image
wavelet_Par    Par=0: single core Par=1 multicore   Par=2 GPU
wavelet_worker  number of core to use (put 0 for max)
nC,nZ, nT dimensions of hyperstack

# Syntax 
Wavelet_filter_func('input.tif','output.tif',1,8,1,0,2,1,1,1000);


# Fiji Wrapper 
Alternatively, the function can be compiled and used in Fiji with a simple wrapper (see Wavelet_filter.m and wavelet a trous.ijm)



Copyright 2022 Derivery lab MRC Laboratory of Molecular Biology

