// The ImageJ macro segments the droplets according to the user input and saves the relevant data
// The code has been tested with ImageJ 1.53t, version 1.8.0_322 as of 29/05/2023


// User directory paths
#@ File (label = "Input directory", description= "Where are the images located ?", style = "directory") input_folder
#@ File (label = "Output directory", description="Where do you want the output images to be located ?",style = "directory") output_folder
#@ String(label = "Lens zoom", choices={"x10","x20","x40"}, description="x10 = 0.65 un,  x20 = 0.33 un,  x30 = 0.16 un",style="radioButtonHorizontal") known_distance
#@ String (label = "Unit?", description="What unit are you using?", value = "um") unit


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



// Setting the scale
if (known_distance=="x10") {
	convert=0.65;
}
if (known_distance=="x20") {
	convert=0.33;
}
if (known_distance=="x40") {
	convert=0.16;
}
scale = "distance=1 known=" + convert + " unit=" + unit;
print("the scale you chose is " + known_distance + ",  meaning that 1 pixel is equal to " + convert + unit);
print("-------------------------------------------------------------------");

// def surffix
suffix = ".tif";

// Creating the directories
TEMPDir = output_folder + File.separator + "temp";
File.makeDirectory(TEMPDir);
ZIPDir = output_folder + File.separator + "zip";
File.makeDirectory(ZIPDir);
CSVDir = output_folder + File.separator + "csv";
File.makeDirectory(CSVDir);


// Function that segments the droplets
function Seg_droplets(folder){
//	run("Enhance Contrast...", "saturated=0.80 normalize");
//	run("Min...", "value=800");
//	run("Max...", "value=9000");
	run("Gaussian Blur...", "sigma=5");
	run("Median...", "radius=5");
	setOption("ScaleConversions", true);
	run("8-bit");
	showMessage("adjust threshold");
	setAutoThreshold("Default dark no-reset");
	run("Threshold...");
	
	// Braking point for user input
	waitForUser('Click Ok after adjusting the threshold');
	
	//setThreshold(36, 255);
	run("Convert to Mask");
	run("Fill Holes");
	run("Watershed");
	
	// Braking point for user input
	waitForUser('Click Ok after manually adjusting the droplets');
	
	// Saving the current image in a temp folder
	file_name = getTitle();
	print("Saving  " + file_name + "  in  " + folder);
	saveAs("Tiff", folder + File.separator + file_name);
	
	run("Fill Holes");
	run("Set Measurements...", "area redirect=None decimal=3");
	setAutoThreshold("Default dark no-reset");
	run("Threshold...");
	run("Analyze Particles...", "size=400.00-Infinity exclude clear add");
}



processFolder(input_folder);

// Function that loops over all tiff files in the input folder
// To automate the processing of large numbers of image files in a batch process 
function processFolder(input_folder) {
	list = getFileList(input_folder);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input_folder + File.separator + list[i]))
			processFolder(input_folder + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input_folder, output_folder, list[i]);
	}
}


// ProcessFile function processes single images
function processFile(input_folder, output_folder, file) {

	print("Processing: " + input_folder + File.separator + file);
	open(input_folder + File.separator + file);
	run("Set Scale...", scale);
	
	// Calling the function that segments the droplets
	Seg_droplets(TEMPDir);
	
	// Changing the name according to the user input
	Chip = "chip name";
	Dialog.create("Chip Name");
	Dialog.addString("Chip_name", Chip);
	Dialog.show();
	Chip = Dialog.getString();

	
	// Saving the files
	print("Saving  " + Chip + ".zip  in  " + ZIPDir);
	roiManager("save", ZIPDir + File.separator + Chip + ".zip")
	print("Saving  " + Chip + ".csv  in  " + CSVDir);
	roiManager("Measure");
	saveAs("Results", CSVDir + File.separator + Chip  + ".csv");
	
	CleanUp();
	// Adding a seperator to the log between files
	print("-------------------------------------------------------------------");
}
