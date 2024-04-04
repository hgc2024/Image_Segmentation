%{
Summarisation of methodology:

The following function has several steps. The image type is first changed
to double. After this, it uses Gaussian smoothing to convolve along each of
four colour channels: Yellow-on-Blue-off, Blue-on-Yellow-off,
Green-on-Red-off, Red-on-Green-off. This lessens noise and helps in
identifying edges. Then the gradient magnitude across the four colour
channels is derived using the Sobel operator. The best high and low
thresholds for hysteresis, which distinguishes between strong and weak
edges and reduces the weak ones, are chose using a histogram. To define the
edges' perimeters, other operations like imdilate to link strong and weak 
edges and bwperim to identify perimeters of the edges, are employed. 
Reverting the picture type back to double is the final step. A series of 
for loops which called on the compare_segmentations.m file were used to 
derive the optimal paramaters, mainly the sigma values for the colour 
channel masks and the high and low threshold for hysteresis thresholding. 
A pair of variables were iterated using a for loop, with the other 
variables hardcoded using either educated guesses or from previous 
solutions derived by old for
loops.

Sources: Lecture and MATLAB practical materials by Dr Michael Spratling for
the Computer Vision
module.
%}
function [seg] = segment_image(I)
    % Convert image to double
    I_double = im2double(I);
    
    % Extract Yellow and Blue Colour Channels
    B = I_double(:,:,3);
    Y = I_double(:,:,1:2);
    R = I_double(:,:,1);
    G = I_double(:,:,2);

    % Assign sigma parameters
    sigma1 = 1.3;
    sigma2 = 1.3;
    sigma3 = 2.2;
    sigma4 = 2.2;

    % Apply Gaussian convolution to each color channel
    GYB1 = fspecial('gaussian', ceil(6*sigma2), sigma1);
    GYB2 = fspecial('gaussian', ceil(6*sigma2), sigma2);
    GGR1 = fspecial('gaussian', ceil(6*sigma4), sigma3);
    GGR2 = fspecial('gaussian', ceil(6*sigma4), sigma4);
    
    % Compute the 'on' and 'off' channels
    Y_on_B_off = conv2(mean(Y,3),GYB1,'same') - conv2(B,GYB2,'same');
    B_on_Y_off = conv2(B,GYB1,'same') - conv2(mean(Y,3),GYB2,'same');
    G_on_R_off = conv2(G,GGR1,'same') - conv2(R,GGR2,'same');
    R_on_G_off = conv2(R,GGR1,'same') - conv2(G,GGR2,'same');

    %% Using Sobel Edge Detection

    % Sobel operator kernels
    sobelX = [-1 0 1; -2 0 2; -1 0 1];
    sobelY = [-1 -2 -1; 0 0 0; 1 2 1];

    % Apply Sobel Edge Detection
    channels = {Y_on_B_off, B_on_Y_off, G_on_R_off, R_on_G_off};
    combined_edges = zeros(size(Y_on_B_off));

    for i = 1:length(channels)
        % Convolve with Sobel operator kernels
        Gx = conv2(channels{i}, sobelX, 'same');
        Gy = conv2(channels{i}, sobelY, 'same');
        
        % Calculate gradient magnitude
        edges = sqrt(Gx.^2 + Gy.^2);
        
        % Build histogram of edge values for the current channel
        [counts, bin] = hist(edges(:), 256);
        
        % Find high threshold - keep top 5% of edges
        cumulative_Counts = cumsum(counts);
        high_threshold_idx = find(cumulative_Counts >= 0.948 * cumulative_Counts(end), 1, 'first');
        high_threshold = bin(high_threshold_idx);
        
        % Find low threshold - keep top 25% of edges
        low_threshold_idx = find(cumulative_Counts >= 0.919 * cumulative_Counts(end), 1, 'first');
        low_threshold = bin(low_threshold_idx);

        % Apply hysteresis
        strong_edges = edges > high_threshold; % Strong edges
        weak_edges = edges > low_threshold & ~strong_edges; % Weak edges
        
        % Linking weak edges with strong edges
        edges = imdilate(strong_edges, strel('disk', 1)) & weak_edges;
        
        % Use bwperim to find the perimeter pixels
        edges = bwperim(edges);
        
        combined_edges = combined_edges | edges; % Combine edges from all channels
    end

    % Convert the contour image to double precision
    seg = im2double(combined_edges);
end
