function [] = Wavelet_filter_func(inputfile,outputfile,wavelet_k1,wavelet_k2,wavelet_Av,wavelet_worker,wavelet_Par,nC,nZ,nT)
tic
%Description
%Wavelet a trous filter using gaussian as a wavelet

%parameters
%inputfile    inputstack (can be >4GB)
%outputfile   ouputstack (bigtiff)
%wavelet_k1  first kernel kept
%wavelet_k2    last kernel kept
%wavelet_Av  if set to 1, filtered image will be averaged with raw image
%wavelet_Par    Par=0: single core Par=1 multicore   Par=2 GPU
%wavelet_worker  number of core to use (put 0 for max)
%nC,nZ, nT dimensions of hyperstack

%syntax 
%Wavelet_filter_func('input.tif','output.tif',1,8,1,0,2,1,1,1000);

%Copyright 2009-2022 Derivery lab MRC Laboratory of Molecular Biology


warning('off','MATLAB:imagesci:tiffmexutils:libtiffWarning');
warning('off', 'imageio:tiffmexutils:libtiffWarning');

n=wavelet_k2+1;

% load input stack

A=tiffreadVolume(inputfile);
nframes=size(A,3);
xysize=[size(A,1) size(A,2)];

if wavelet_Par<2
    Input=cell(1,nframes);
    for i=1:nframes
        Input{1,i}=A(:,:,i);
    end

    % create the gaussian kernels
    I=1; %(this way it's normalized)
    bg=0;
    Gauss=cell(1,n);

    if wavelet_Par==1
        if wavelet_worker==0
            if isempty(gcp('nocreate'))==1
                parpool('local'); %for max worker
                h=gcp; %start parpool  
            end
        else
            if isempty(gcp('nocreate'))==1
                parpool('local',wavelet_worker); %for 20 workers
                h=gcp; %start parpool 
            else
                p = gcp('nocreate');
                poolsize = p.NumWorkers;
                if poolsize<wavelet_worker
                     delete(gcp('nocreate'));
                     parpool('local',wavelet_worker); %for 20 workers
                     h=gcp; %start parpool 
                end              
            end         
        end

        parfor j=1:n
        Gauss{1,j}=finitegausspsf(20*j,j,I,bg,[10*j 10*j]);
        end
    else
       for j=1:n
        Gauss{1,j}=finitegausspsf(20*j,j,I,bg,[10*j 10*j]);
        end 
    end
    %%%

    output=cell(1,nframes);

    if wavelet_Par==1
        parfor i=1:nframes
            Convol=cell(1,n);
                for j=1:n
                    Convol{1,j}=imfilter(Input{1,i},Gauss{1,j},'circular','conv');
                end
            Sub=cell(1,n-1);
                for j=1:n-1
                   Sub{1,j}=Convol{1,j}-Convol{1,j+1} ;
                end
            Temp=uint16(zeros(xysize));
                for j=wavelet_k1:wavelet_k2
                    Temp=Temp+Sub{1,j}(:,:);
                end

            if wavelet_Av==1
            output{1,i} = (Temp + Input{1,i})./2;
            else
            output{1,i}=Temp;
            end
        end
    else
        for i=1:nframes
            Convol=cell(1,n);
                for j=1:n
                    Convol{1,j}=imfilter(Input{1,i},Gauss{1,j},'circular','conv');
                end
            Sub=cell(1,n-1);
                for j=1:n-1
                   Sub{1,j}=Convol{1,j}-Convol{1,j+1} ;
                end
            Temp=uint16(zeros(xysize));
                for j=wavelet_k1:wavelet_k2
                    Temp=Temp+Sub{1,j}(:,:);
                end

            if wavelet_Av==1
            output{1,i} = (Temp + Input{1,i})./2;
            else
            output{1,i}=Temp;
            end
        end
    end
 


else %GPU implementatiom
    %p=gpuDevice;
    %display(cat(2,p.Name,' GPU detected'));
    I=1; %(this way it's normalized)
    bg=0;
    
  Input=cell(1,nframes);
for i=1:nframes
    Input{1,i}=gpuArray(single(A(:,:,i)));
end

    for j=1:n
        %Gauss{1,j}=finitegausspsf(20*j,j,I,bg,[10*j 10*j]);
        Gauss{1,j}=gpuArray((finitegausspsf(20*j,j,I,bg,[10*j 10*j])));
    end
    output=cell(1,nframes);

    for i=1:nframes

        Convol=cell(1,n);
        for j=1:n
            Convol{1,j}=imfilter(Input{1,i},Gauss{1,j},'circular','conv');
        end

        Sub=cell(1,n-1);

        for j=1:n-1
           Sub{1,j}=Convol{1,j}-Convol{1,j+1} ;
        end

        Temp=gpuArray(single(zeros(xysize)));

        for j=wavelet_k1:wavelet_k2
            Temp=Temp+single(Sub{1,j}(:,:));
        end

        if wavelet_Av==1
            output{1,i}=uint16(gather((Temp+Input{1,i})./2));   
        else
            output{1,i}=uint16(gather(Temp));
        end   
    end
    
end

out=Tiff(outputfile,'w8'); %bigtiff if not, it's not working
for i=1:nframes
tagstruct.ImageLength = size(output{1,1},1);
tagstruct.ImageWidth = size(output{1,1},2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 16;
tagstruct.SamplesPerPixel = 1;
tagstruct.RowsPerStrip = 16;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tagstruct.Software = 'MATLAB';
setTag(out,tagstruct);
deschar = sprintf('ImageJ=1.51\nnimages=%d\nchannels=%d\nslices=%d\nframes=%d\nhyperstack=true\nmode=grayscale\nloop=false\nmin=68\nmax=200\n',nC*nZ*nT, nC, nZ, nT);
setTag(out,270,deschar)
write(out,output{1,i});
writeDirectory(out); 
end
display(cat(2,'Elapsed time is ',num2str(toc),' sec for ',num2str(nframes),' frames'));
close(out);
end

