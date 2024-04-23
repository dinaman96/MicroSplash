# Image Processing Workflow README

This document provides a brief overview of the workflow for processing TIFF images through various stages. Follow the steps below to ensure proper organization and execution of the image processing tasks.

## Folder Structure

Please create and organize your files into the following directories:

1. **RGB_Image** - This is the root folder for initial TIFF images.
   - **Chips** - Within **RGB_Image**, create a folder named "Chips" to store images by chip type (e.g., B3, C3).
     - **Aligned** - A folder within **RGB_Image** that contains chip-specific folders with aligned images from the first processing code.
2. **HDF5 Files** - Contains images after being cropped and converted to HDF5 format.
3. **Segmented** - Stores images after Ilastik segmentetion.
4. **Droplets** - Holds images with identified droplets. 
   - **Alexa** - Within **Droplets**, create a folder named "Alexa" to store images for each chip to place selected time point images of the Alexa channel for segmentation.
5. **Results** - Stores the final output images and any analytical results.

## Processing Steps

### Step 1: Preparing and Aligning Images

- **Script Name**: `1_CropLargeImage_Align_120324.ijm`
- **Purpose**: This script is designed to process large temporal sequence images by cropping a defined region, aligning the cropped images using the Scale-Invariant Feature Transform (SIFT) method, and then applying these alignment adjustments back to the original large images. It ensures that each image in the sequence is properly aligned for accurate time-lapse analysis.
- **Input**: Time-point images of the GFP channel within the **Chips** directory. 
- **Output**: Choose the **Aligned** folder as the output directory.
- **Execution**: Run the code separately for each chip. Specify the chip name for organized output file saving.


### Step 2: Image Cropping and Conversion to HDF5 Format

- **File Name**: `2_ConvertHDF5_140324.ijm`
- **Purpose**: This script takes the aligned images from each chip's folder within the **Aligned** directory, crops a sample of these images, and converts the sample and large images to the HDF5 format. 
- **Input**: The chip-specific folders within the **Aligned** directory.
- **Output**: Choose the **HDF5 Files** folder, where two new directories are created: HDF5 Large Files and HDF5 Cropped Files.
- **Execution**: Run the code separately for each chip. Specify the chip name for organized output file saving.


### Step 3: Cell Segmentation and Validation

Part A: Cell Segmentation with Ilastik
1. **Procedure**: Use Ilastik for pixel classification on the cropped HDF5 files. Process each chip's images separately to achieve accurate segmentation results.
2. **Feature Selection**:
   - Enable all the color sigma options.
   - Choose the following scales for edge and texture features: 0.3, 0.7, 1, 1.6, and 3.5.
3. **Labeling**:
   - Rename `label1` to `BK` (Background), and label the rest as `GFP`, `Mcherry`, or other relevant markers based on your project needs.
   - Carefully label the background and bacteria in your images. After initial labeling, navigate through the rest of the time points to adjust your labeling until satisfactory segmentation results are achieved.
4. **Exporting**:
   - Change the exporting settings in Ilastik to TIFF format.
   - Batch export all the **large HDF5** images of the chip to ensure all processed images are saved in a consistent format.
   - Move the exported Tif files to the **Segmented** folder.

Part B: Validation of Cell Segmentation
- **File Name**: `3_BacterialValidation_310324.ijm`
- **Purpose**: Following cell segmentation, this script generates Regions of Interest (ROIs) from the segmented images. These ROIs facilitate the visual validation of the segmentation accuracy on the original GFP images, ensuring the segmentation effectively captures the cellular structures.
- **Input**: The chip-specific folders within the **Segmented** folder.
- **Output**: ROIs are saved in a zip file format within the **Segmented** folder.
- **Execution**: Choose or create an output directory where the ROI zip files will be stored. Run the code separately for each chip.
- **Validate Segmentation**: Load the ROIs onto the original GFP images to visually inspect and confirm the accuracy of the cell segmentation process.

### Step 4: Segmenting Droplets

- **File Name**: `4_SegmentDroplets.ijm`
- **Purpose**: This script is designed to segment droplets from images within the Alexa channel of each chip. It applies a series of image processing techniques, including Gaussian Blur, Median Filter, and threshold adjustments, to segment and analyze droplets effectively.
- **Input**: Place the chosen time point image of the Alexa channel for each chip inside the **Alexa** folder within the **Droplets** directory. The script will process these images to segment the droplets.
- **Output**: For each processed image, the script saves:
  - A `.zip` file containing the segmented droplets' ROI (Region of Interest) data.
  - A `.csv` file with measurements derived from the segmented droplets.
  - These files are saved in the **Results** directory, organized by the chip name and the original image name.

## Notes
- Adjustments to code parameters or manual selections (e.g., during threshold adjustment) may be necessary based on your specific image characteristics or desired outcomes.

### Step 5: Counting Bacteria in Droplets

- **File Name**: `5_CountBacteria.ijm`
- **Purpose**: This macro is tailored for counting bacteria within segmented droplets, with the capability to distinguish between different bacteria types based on object values. It efficiently processes each ROI, applies segmentation to separate bacteria types, and counts them accordingly.
- **Input**:
  - **Segmented Folder**: This folder should contain subfolders for each chip with their segmented images. Each chip's folder is processed separately to ensure accurate counting within droplets.
  - **ROI Folder**: This additional input directory must include `.zip` files containing the ROIs of droplets for each chip. The zip file names should match the corresponding chip folder names within the **Droplets** directory for consistency.
- **Output**: The script generates output files in the **Results** folder. For each image processed, it creates a `.csv` file containing the count and other measurements for bacteria within each droplet. The naming convention for output files considers the bacteria type, ensuring easy identification and analysis.
- **Execution Notes**:
  - Ensure the **Segmented** folder is prepared with the correctly named subfolders for each chip.
  - The **ROI Folder** should be organized with `.zip` files named after each chip's segmented images, reflecting the droplets' ROIs.
  - The **Results** folder will be populated with `.csv` files detailing the bacteria counts and measurements, organized by the chip and bacteria type.
  - User input is required to specify the number of bacteria types present in the experiment. The script allows for dynamic entry of bacteria type names, facilitating flexible analysis across different datasets.


## Notes
- Running this macro requires careful attention to the naming and organization of input files and folders to ensure accurate processing and output generation.
- Manual adjustments or selections may be necessary during the execution, particularly when adjusting thresholds or selecting ROIs for counting. Be prepared to interact with the ImageJ interface during processing.

