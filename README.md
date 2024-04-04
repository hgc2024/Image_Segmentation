# Image_Segmentation

The image segmentation is done by running the segment_image.m on the images in the training data. The segment_image.m file has the following steps:

1. Change the image type to double.
2. Convolve each image using Gaussian smoothing along four colour channels: Yellow-on-Blue-off, Blue-on-Yellow-off, Green-on_Red-off, Red-on-Green-off.
3. Derive the gradient magnitude across the four colour channels using the Sobel operator for each image.
4. Use histograms to derive the best high and low thresholds using hysteresis thresholding.
5. Convert the images back to double image type.

The performance of the model should be approximately 69% accurate, which is close to human-level performance of 80%.
