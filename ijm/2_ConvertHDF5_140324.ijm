
// The code has been designed to work with ImageJ and its HDF5 plugin. This macro iterates through all files in the input directory. 
// For each image, it first converts and saves the image in the HDF5 format in the 'large' directory.
// If cropping is enabled, it then crops the image to the specified dimensions, converts the cropped image to HDF5 format, and saves it in the 'cropped' directory.
// The code has been tested with ImageJ 1.54i, version March 2024 as of 31/03/2024

#@ File (label = "Input directory", style = "directory") input_folder
#@ File (label = "Output directory", style = "directory") output_folder
#@ String (label = "Chip name", description="What is the name of the chip?") chip
#@ String (label = "File suffix", value = ".tif") suffix
#@ Integer (label = "Crop Width", value = 4000, min = 0) cropWidth
#@ Integer (label = "Crop Height", value = 4000, min = 0) cropHeight
#@ Boolean (label = "Crop images?", value = true) doCrop



input_folder += File.separator;
output_folder += File.separator;

largeHDF5DirPath = output_folder + chip + "Large_HDF5" + File.separator;
croppedHDF5DirPath = output_folder + chip + "Cropped_HDF5" + File.separator;

File.makeDirectory(largeHDF5DirPath);
File.makeDirectory(croppedHDF5DirPath);

function processFolder(folderPath, outputLargeDir, outputCroppedDir, crop, cropWidth, cropHeight) {
    list = getFileList(folderPath);
    for (i = 0; i < list.length; i++) {
        if (endsWith(list[i], suffix)) {
            processFile(folderPath, outputLargeDir, outputCroppedDir, list[i], crop, cropWidth, cropHeight);
        }
    }
}

function processFile(inputDir, outputLargeDir, outputCroppedDir, fileName, crop, cropWidth, cropHeight) {
    open(inputDir + fileName);
    imageTitle = getTitle();
    
    largeHDF5Path = outputLargeDir + fileName.replace(suffix, ".h5");
    //run("Export HDF5", "select=[" + largeHDF5Path + "] exportpath=[" + largeHDF5Path + "] datasetname=data compressionlevel=0 input=[" + imageTitle + "]");

    if (crop) {
        makeRectangle(7000, 7000, cropWidth, cropHeight); //Make sure the cordinates match your images!!!!
        run("Crop");
        croppedHDF5Path = outputCroppedDir + fileName.replace(suffix, "_cropped.h5");
        run("Export HDF5", "select=[" + croppedHDF5Path + "] exportpath=[" + croppedHDF5Path + "] datasetname=data compressionlevel=0 input=[" + getTitle() + "]");
    }
    
    run("Close All");
}

processFolder(input_folder, largeHDF5DirPath, croppedHDF5DirPath, doCrop, cropWidth, cropHeight);

