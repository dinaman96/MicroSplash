// This ImageJ macro counts objects (bactria) in each ROI (droplet)
// It counts the objects (bactria) according to its different object value (different bactria types)
// This code is based on Daniel Waiger code: https://github.com/image-analysis/nuclei-counter/tree/V1.1
// The code has been tested with ImageJ 1.53t, version 1.8.0_322 as of 29/05/2023


// User input for the directories and number of bactria
#@ File (label = "Segmented images", description= "The input folder should contain a folder for each chip \nMake sure that the chip folders named the same as the zip Roi ", style = "directory") input_folder
#@ File (label = "Output folder", description= "Where you want the output files to be located in", style = "directory") output_folder
#@ File (label = "ROI Folder", description= "Roi folder should contain zip files of all the droplets of each chip", style = "directory") roi_folder
#@ Integer (label="Number of bactria", description= "How many bactria were in the experiment", style="slider", min=1, max=5, stepSize=1) bactria


// Function that closes all open windows and resets ROI Manager
function CleanUp() { 
	roiManager("reset");
	run("Close All");
	wlist=getList("window.titles");
	wlength=lengthOf(wlist);
	for (i=0; i<wlength; i++) {
		if (wlist[i] != "log") {
			selectWindow(wlist[i]);
			run("Close");
		}}}
		
		
CleanUp();
print("\\Clear");


// Function that gets user input regarding the names of the bactria
var bactria_types = newArray();
function GetName(bactria) { 
	if (bactria==1) {
		return "";
		}
	else{
		Dialog.create("Bactria Type");
		for (K = 0; K < bactria; K++) {
			bactria_types = Array.concat(bactria_types, "bactria_type_" + K);
			Dialog.addString("Bactria type "  + K , bactria_types[K]);
			}
		Dialog.show();
		for (K = 0; K < bactria; K++) {
			bactria_types[K] = Dialog.getString();
			print("bactria number  " + K + "  is " + bactria_types[K]);
		}
		return bactria_types;
	
			} }

bac = GetName(bactria);

// def surffix
suffix = ".tif";

// Debugging option to limit the number of input files to be processed
max_files=100;
max_rois=100000000;


// Function that segments the bactria separately
function processBactria(bactria_num){
	number= parseInt(bactria_num) + 1;
	run("glasbey");
	changeValues(0, number-1, 1);
	changeValues(number+1, 6, 1);
	setThreshold(number, number);
}


// InputDir (direcotry) is a collection of Folders.
// The function processDir deals with processing every single Folder in the Dir and writes the results to outputDir.
// The inputDir and outputDir paths are given by the user.
// The Folders inside outputDir are created by processDir with the same names for equivalent Folders in inputDir.
function processDir(inputDir, outputDir, roi_folder) {
	listdir = getFileList(inputDir);
	for (j = 0; j < listdir.length; j++) {
		if (File.isDirectory(inputDir + File.separator + listdir[j])){
			// Adding a seperator to the log between folders
			print("-------------------------------------------------------------------");
			print("Processing: " + listdir[j]);
		
			File.makeDirectory(outputDir + File.separator + listdir[j]);
			outputFolder = outputDir + File.separator + listdir[j];
			inputFolder = inputDir + File.separator + listdir[j];
			roi_dir = roi_folder + File.separator + substring(listdir[j],0,lengthOf(listdir[j])-1) + ".zip";
			processFolder(inputFolder, outputFolder, roi_dir);

		}}
	}


// Calling the function processDir
processDir(input_folder, output_folder, roi_folder);


// Function that loops over all objects masks files in the input folder
// To automate the processing of large numbers of image files in a batch process 
function processFolder(input_folder, outputFolder, roi_dir) {
	list = getFileList(input_folder);
	for (j = 0; j < list.length; j++){
		if (File.isDirectory(input_folder + File.separator + list[j]));
		processFolder("" + input_folder + File.separator + list[j], outputFolder, roi_dir);
		if (endsWith(list[j], ".tif")){
			processFile(input_folder, outputFolder, list[j], roi_dir);
			}
		if (endsWith(list[j], ".tiff")){
			processFile(input_folder, outputFolder, list[j], roi_dir);
			}
		}}


// ProcessFile function processes single images
function processFile(input_folder, output_folder, file, roi_dir) {
	
	// Setting BatchMode to True to optimize the memory usage
	setBatchMode(true);
	
	// Segmenting and processing only one bactria each time
	num_of_bac = parseInt(bactria);
	
	for(i = 1; i <= num_of_bac; i++){
		
		// Loading Nuclear ROIs from roi_folder
		run("ROI Manager...");
		roiManager("Open", roi_dir);
	
		// Counting objects inside each roi in each ROIs
		num_of_ROIs = roiManager("count");

		// Selecting object mask file and opening it 
		open(input_folder + file);
		
		// Renaming the image according to the user input
		file_name_wo_suffix = File.getNameWithoutExtension(input_folder + file);
		a = toString(i);
		
		if (bactria==1) {
			new_name = file_name_wo_suffix;
		}
		else{
			B = i-1;
			Bac_type = bac[B];
			new_name = Bac_type + "_" + file_name_wo_suffix;
			}
		rename(new_name);
		
		// Calling the function that segments only one bactria
		processBactria(i);
		
		// Counting the bactria in each droplet (ROI)
		for(j=0; j<num_of_ROIs && j<max_rois; j++){
			roiManager("Select", j);
			run("Set Measurements...", "area perimeter display redirect=None decimal=3");
			run("Analyze Particles...", "clear");
			run("Analyze Particles...", "summarize add");
			}
			
		// Saving the Results from summary window to a csv file
		selectWindow("Summary");
		print("Saving  " + new_name + ".csv   in  " + output_folder);
		saveAs("Results",  output_folder + File.separator + new_name + ".csv");
		
		CleanUp();
	}}

print("\n done");