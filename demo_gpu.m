%% DEMO of VSA environment scripting
clear all
close all

% Identify and select the GPU device
gpuInfo = gpuDevice(1);
disp(['Using GPU: ', gpuInfo.Name]);

% create the object of a specific VSA type
vsa_types = {'MAP_C', 'MAP_B', 'MAP_I', 'BSC', 'BSDC', 'BSDC_SHIFT', 'BSDC_SEG', 'HRR', 'FHRR'};

for type_idx = 1:length(vsa_types)
    type = vsa_types{type_idx};
    VSA = vsa_env('vsa',type,'dim',1024);

    % Load images from a directory
    imageDir = '/MATLAB Drive/VSA_Toolbox-master/+experimental_scripts/GardensPointWalking/night_right';
    imageFiles = dir(fullfile(imageDir, '*.jpg')); % or '*.png' based on your image format

    % Initialize the combined vectors as GPU arrays
    combinedVector = gpuArray([]);
    combinedVector1 = gpuArray([]);

    % Iterate through each image and convert it to a vector
    for i = 1:length(imageFiles)/2
        currentFileName = imageFiles(i).name;
        currentImagePath = fullfile(imageDir, currentFileName);

        % Read the image
        img = imread(currentImagePath);
        squareSize = 256;
        img = rgb2gray(imresize(img, [squareSize, squareSize]));
        imgVector = gpuArray(reshape(img, [], 1));
        combinedVector = [combinedVector, imgVector];
    end
    
    VSA.add_vector('vec',gpuArray(double(combinedVector)));
    combinedVector1 = [];

    % Iterate through each image and convert it to a vector
    for i = length(imageFiles)/2 + 1:length(imageFiles)
        currentFileName = imageFiles(i).name;
        currentImagePath = fullfile(imageDir, currentFileName);

        % Read the image
        img = imread(currentImagePath);
        squareSize = 256;
        img = rgb2gray(imresize(img, [squareSize, squareSize]));
        imgVector = gpuArray(reshape(img, [], 1));
        combinedVector1 = [combinedVector1, imgVector];
    end
    [rows, cols] = size(combinedVector);
    [rows1, cols1] = size(combinedVector1);

    if cols ~= cols1
        % Remove the last index of the longer vector to make them equal
        minLength = min(cols, cols1);
        combinedVector1(:, minLength+1:end) = [];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 1. bundling
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['Bundling vectors for VSA type: ' type]);
    tic;
    
    if ~strcmp(type, 'FHRR')
        v_array_1 = VSA.add_vector('vec',gpuArray(double(combinedVector))); 
        v_array_2 = VSA.add_vector('vec',gpuArray(double(combinedVector1)));
        bundle=VSA.bundle(v_array_1, v_array_2);
    end

    elapsedTime = toc;
    disp(['Elapsed time: ' num2str(elapsedTime) ' seconds']);
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 2. binding / unbinding
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['Binding vectors for VSA type: ' type]);
    tic;
    v_array_1 = VSA.add_vector('vec',gpuArray(double(combinedVector))); 
    v_array_2 = VSA.add_vector('vec',gpuArray(double(combinedVector1)));

    bound_v = VSA.bind(gather(v_array_1), gather(v_array_2));
    elapsedTime = toc;

    if strcmp(type, 'BSDC')
        % Use similarity search for BSDC
        [v_clean, name, s] = VSA.find_k_nearest(gpuArray(bound_v), 1);
        sim_v1 = gather(s);
        disp(['Elapsed time: ' num2str(elapsedTime) ' seconds']);
        disp('------- unbinding:');
    else
        % Regular unbinding operation for other VSA types
        r = VSA.unbind(gather(v_array_1), gather(bound_v));
        disp(['Elapsed time: ' num2str(elapsedTime) ' seconds']);
        sim_v1 = VSA.sim(gather(r), gather(v_array_1));
        sim_v2 = VSA.sim(gather(r), gather(v_array_2));
        disp('------- unbinding:');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 3. use the item memory to find vectors
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(['Finding k vectors for VSA type: ' type]);
    % fill the item memory with random vectors
    VSA = vsa_env('vsa',type,'dim',65536);

    v_array_1 = VSA.add_vector('vec',gpuArray(double(combinedVector(:,1))));
    v = VSA.add_vector('name','probe');
    [v_clean, name, s] = VSA.find_k_nearest(gpuArray(double(v)),1);

    % Convert similarity to percentage for BSDC types
    if strcmp(type, 'BSDC') || strcmp(type, 'BSDC_SHIFT') || strcmp(type, 'BSDC_SEG')
        % Convert raw similarity scores to decimal format for BSDC types
        similarity_decimal = gather(s) / 1024;  % Convert to decimal format
        disp(['Found probe vector with similarity of ', num2str(similarity_decimal, '%.5f')]);
    else
        % For other types, display similarity as is
        disp(['Found probe vector with similarity of ', num2str(gather(s), '%.5f')]);
    end

    % bundle the probe with noise vector
    noise = VSA.add_vector('add_item',0);
    bundle = VSA.bundle(v,noise);
    [v_clean, name, s] = VSA.find_k_nearest(gpuArray(bundle),1);

    % Convert similarity to decimal format for BSDC types
    if strcmp(type, 'BSDC') || strcmp(type, 'BSDC_SHIFT') || strcmp(type, 'BSDC_SEG')
        s = gather(s) / 1024;  % Convert to decimal format
        disp(['Found noisy vector probe with similarity of ', num2str(s, '%.5f')]);
    else
        disp(['Found noisy vector with similarity of ', num2str(gather(s), '%.5f')]);
    end
end