%% ECE 210 Extra Credit: Simplified JPEG-like Compression
% This script implements a basic image compression scheme based on
% dividing an image into 8x8 blocks, applying the 2D DCT, quantizing
% coefficients, and reconstructing the image.

% Housekeeping
clear;
close all;
clc;

%% Configuration
% --- USER INPUT REQUIRED ---
% Specify the path to your input image file.
% Choose an image that is reasonably complex (not just flat colors).
% Example: image_path = 'cameraman.tif'; % Built-in MATLAB image
% Example: image_path = 'my_interesting_image.png';
image_path = 'cameraman.tif'; %<-- CHANGE THIS TO YOUR IMAGE PATH

% Define the number of top DCT coefficients to keep per block
num_coeffs_to_keep = 8;

% Define block size (standard for JPEG is 8x8)
block_size = 8;

%% Part 1: Pre-Processing

fprintf('--- Part 1: Pre-Processing ---\n');

% --- Load and Prepare Image ---
try
    original_image_color = imread(image_path);
catch ME
    error('Could not read image file: %s\nPlease ensure the path is correct and the file exists.\nError details: %s', image_path, ME.message);
end

% Convert to monochrome (grayscale) if necessary
if size(original_image_color, 3) == 3
    fprintf('Input image is RGB, converting to monochrome.\n');
    original_image_mono = rgb2gray(original_image_color);
else
    fprintf('Input image is already monochrome.\n');
    original_image_mono = original_image_color;
end

% Convert image to double precision in the range [0, 1] for calculations
% Using double provides better precision for DCT calculations.
original_image_double = im2double(original_image_mono);
[original_rows, original_cols] = size(original_image_double);
fprintf('Original image size: %d x %d\n', original_rows, original_cols);

% --- Pad Image ---
% Calculate necessary padding to make dimensions multiples of block_size (8)
rows_to_pad = mod(block_size - mod(original_rows, block_size), block_size);
cols_to_pad = mod(block_size - mod(original_cols, block_size), block_size);

% Pad the image with zeros (black pixels) at the bottom and right edges
% 'replicate' or 'symmetric' could also be used but padding with 0 is simple
% and specified as an acceptable method in the prompt.
padded_image = padarray(original_image_double, [rows_to_pad, cols_to_pad], 0, 'post');
[padded_rows, padded_cols] = size(padded_image);
fprintf('Padded image size: %d x %d\n', padded_rows, padded_cols);

% --- Reshape into 8x8 Tiles ---
% Use im2col to rearrange image blocks into columns. 'distinct' processes
% non-overlapping blocks. Each column represents one 8x8 block (64 elements).
% The resulting matrix `blocks_as_cols` will be (block_size*block_size) x N,
% where N is the total number of blocks.
N_rows_blocks = padded_rows / block_size;
N_cols_blocks = padded_cols / block_size;
num_blocks = N_rows_blocks * N_cols_blocks;

blocks_as_cols = im2col(padded_image, [block_size block_size], 'distinct');

% Reshape the columns into a 3D array: block_size x block_size x num_blocks
% Each "slice" along the 3rd dimension is one 8x8 tile.
image_tiles = reshape(blocks_as_cols, block_size, block_size, num_blocks);
fprintf('Reshaped image into %d tiles of size %dx%d.\n', num_blocks, block_size, block_size);

% --- Plot Some Tiles (Verification) ---
figure;
num_tiles_to_plot = min(num_blocks, 16); % Plot up to 16 tiles
plot_grid_size = ceil(sqrt(num_tiles_to_plot));
sgtitle('Sample 8x8 Tiles from Padded Image');
for i = 1:num_tiles_to_plot
    subplot(plot_grid_size, plot_grid_size, i);
    imshow(image_tiles(:,:,i)); % Display each tile
    title(sprintf('Tile %d', i));
end
fprintf('Plotted first %d tiles for verification.\n', num_tiles_to_plot);

%% Part 2: DCT Energy Analysis

fprintf('\n--- Part 2: DCT Energy Analysis ---\n');

% Initialize storage for DCT coefficients and histogram
dct_tiles = zeros(size(image_tiles), 'double'); % Store DCT results (use double)
top_indices_linear = zeros(num_coeffs_to_keep, num_blocks); % Store linear indices of top coeffs

% --- Apply 2D DCT to each tile and find top coefficients ---
for i = 1:num_blocks
    % Calculate 2D DCT for the current tile
    current_tile = image_tiles(:,:,i);
    dct_tiles(:,:,i) = dct2(current_tile);

    % Find the indices of the top N coefficients by magnitude
    [~, sorted_indices] = sort(abs(dct_tiles(:,:,i)), 'descend'); % Sort magnitudes within the 8x8 tile
    % Note: sort operates column-wise by default. We need indices across the *whole* 8x8 block.
    [~, sorted_linear_indices] = sort(abs(dct_tiles(:,:,i)(:)), 'descend'); % Sort flattened tile magnitudes
    
    top_indices_linear(:, i) = sorted_linear_indices(1:num_coeffs_to_keep); % Store top linear indices
end
fprintf('Calculated 2D DCT for all %d tiles.\n', num_blocks);
fprintf('Identified top %d DCT coefficients (by magnitude) for each tile.\n', num_coeffs_to_keep);

% --- Create 2D Histogram of Top Coefficient Locations ---
% We want an 8x8 histogram where each bin (r, c) counts how many times
% the DCT coefficient at position (r, c) was among the top N across all tiles.

% Use accumarray for efficient histogramming.
% `top_indices_linear(:)` creates one long vector of all top indices across all blocks.
% The second argument '1' specifies the value to accumulate (count 1 for each occurrence).
% `[block_size*block_size, 1]` specifies the size of the output accumulation vector (64x1).
histogram_linear = accumarray(top_indices_linear(:), 1, [block_size*block_size, 1]);

% Reshape the linear histogram (64x1) into an 8x8 matrix
dct_location_histogram = reshape(histogram_linear, block_size, block_size);

fprintf('Generated 8x8 histogram of top DCT coefficient locations.\n');

% --- Plot DCT Location Histogram ---
figure;
imagesc(log10(dct_location_histogram + 1)); % Plot on log scale (+1 to avoid log(0))
colormap(gca, 'parula'); % Use a visually distinct colormap
colorbar;
axis square;
title(sprintf('Log Frequency Plot: Top %d DCT Coefficient Locations', num_coeffs_to_keep));
xlabel('DCT Coefficient Column Index');
ylabel('DCT Coefficient Row Index');
xticks(1:block_size);
yticks(1:block_size);
% Annotate counts on the histogram (optional, can be cluttered)
% for r = 1:block_size
%     for c = 1:block_size
%         text(c, r, num2str(dct_location_histogram(r,c)), ...
%              'HorizontalAlignment', 'center', 'Color', 'white', 'FontSize', 8);
%     end
% end

%% Part 3: Quantization & Reconstruction

fprintf('\n--- Part 3: Quantization & Reconstruction ---\n');

% Initialize storage for quantized DCT tiles and reconstructed tiles
quantized_dct_tiles = zeros(size(dct_tiles), 'single'); % Store as single precision
reconstructed_tiles = zeros(size(image_tiles), 'double'); % Reconstruct back to double first

% --- Quantize DCT coefficients and Apply Inverse DCT ---
for i = 1:num_blocks
    % Get the DCT coefficients for the current tile
    current_dct_tile = dct_tiles(:,:,i);
    
    % Create a mask to keep only the top N coefficients
    mask = false(block_size, block_size);
    mask(top_indices_linear(:, i)) = true; % Mark top coefficient locations

    % Zero out coefficients not in the top N
    quantized_tile_double = current_dct_tile .* mask;
    
    % Convert the resulting tile to single precision (as per "half precision floats" suggestion)
    % Using 'single' as 'half' requires Deep Learning Toolbox and might not be necessary.
    % If 'half' is available and desired: quantized_dct_tiles(:,:,i) = half(quantized_tile_double);
    quantized_dct_tiles(:,:,i) = single(quantized_tile_double);

    % Apply Inverse DCT to reconstruct the tile
    % Use double precision for idct2 for accuracy before potential display scaling
    reconstructed_tiles(:,:,i) = idct2(double(quantized_dct_tiles(:,:,i)));
end
fprintf('Quantized DCT coefficients (kept top %d, converted to single) for all tiles.\n', num_coeffs_to_keep);
fprintf('Reconstructed image tiles using Inverse DCT.\n');


% --- Reshape Tiles Back into Padded Image ---
% Use col2im to reverse the im2col operation.
% Reshape the 3D array of tiles back into a 2D matrix where each column is a block.
reconstructed_blocks_as_cols = reshape(reconstructed_tiles, block_size*block_size, num_blocks);

% Rearrange the columns back into the padded image format.
reconstructed_padded_image = col2im(reconstructed_blocks_as_cols, [block_size block_size], [padded_rows padded_cols], 'distinct');
fprintf('Reassembled tiles into padded image format (%d x %d).\n', padded_rows, padded_cols);

% --- Remove Padding ---
% Crop the reconstructed image to the original dimensions
reconstructed_image = reconstructed_padded_image(1:original_rows, 1:original_cols);
fprintf('Removed padding to get final reconstructed image (%d x %d).\n', original_rows, original_cols);

% --- Display Results ---
figure;
subplot(1, 2, 1);
imshow(original_image_double); % Display original monochrome image (double [0,1])
title('Original Monochrome Image');

subplot(1, 2, 2);
imshow(reconstructed_image); % Display reconstructed image (should also be double [0,1])
title(sprintf('Reconstructed Image (Top %d DCT Coeffs per Block)', num_coeffs_to_keep));

sgtitle('Image Compression Results');

% --- Optional: Calculate Quality Metrics ---
try
    psnr_value = psnr(reconstructed_image, original_image_double);
    ssim_value = ssim(reconstructed_image, original_image_double);
    fprintf('\n--- Quality Metrics ---\n');
    fprintf('PSNR: %.2f dB\n', psnr_value);
    fprintf('SSIM: %.4f\n', ssim_value);
catch ME_metrics
    fprintf('\nCould not calculate PSNR/SSIM. Image Processing Toolbox might be required.\n');
    % disp(ME_metrics.message); % Uncomment for details
end

fprintf('\n--- Processing Complete ---\n');