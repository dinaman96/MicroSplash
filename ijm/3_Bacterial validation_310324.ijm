// For each segmented time point image, this code creates a ROI for visual validiation of bacterial segmentataion

// Define input and output folders
#@ File (label = "Folder where objects masks are located", style = "directory") inputFolder
#@ File (label = "Folder where output files will be written", style = "directory") outputFolder
#@ String (label = "Chip name", description="Enter the name of the chip for organizing output files:") chipName


// Add trailing slashes to the input and output directories
inputFolder = inputFolder + "/";
outputFolder = outputFolder + "/";

// Create a new directory inside the output folder based on the chip name
chipFolder = outputFolder + chipName + "/";
File.makeDirectory(chipFolder);

// Define the file suffix to look for
suffix = ".tif";

// Get a list of files in the input folder
list = getFileList(inputFolder);

// Loop through each file in the list
for (i = 0; i < list.length; i++) {
  // Check if the file has the correct suffix
  if (endsWith(list[i], suffix)) {
    processFile(inputFolder, chipFolder, list[i]);
  }
}

function processFile(input_folder, output_folder, file) {
  // Open the image
  open(input_folder + file);
  // Reset the ROI
  roiManager("reset");
  // Apply the Glasbey LUT and threshold the image
  run("glasbey");
  run("Threshold...");
  setThreshold(2, 255);

  // Analyze the particles and display the results
  run("Set Measurements...", "area perimeter display redirect=None decimal=3");
  run("Analyze Particles...", "summarize add");

  // Save the ROIs as a zip file in the output folder
  name = file;
  roiManager("save", output_folder + name + ".zip");

  // Close the image
  close();
}

