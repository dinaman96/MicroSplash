
// The ImageJ macro crops a small part of large images, creates a stack from the cropped images,
// aligns the stack linearly with SIFT, and applies the transformation shifts to the large images.
// The code has been tested with ImageJ 1.54f, as of 11/04/2024

// User directory paths
#@ File (label = "Input directory", description= "Images locatation", style = "directory") input_folder
#@ File (label = "Output directory", description="Images output", style = "directory") output_folder
#@ String (label = "Experiment time", description="Experiment duration", value = ".tif") hours
#@ String (label = "Time between images", description="Time between two images", value = ".tif") delta
#@ String (label = "Chip name", description="Chip name", value = ".tif") chip

cropX = 7100; // X coordinate of the crop rectangle's top-left corner
cropY = 6100; // Y coordinate
cropWidth = 2400; // Width of the crop rectangle
cropHeight = 1800; // Height (should be smaller than Width!)

// Directories edits
sourceDir = input_folder + File.separator;
output_folder = output_folder  + File.separator;
suffix = ".tif";

run("Close All");
setBatchMode(true);

// Get list of files in directory
list = getFileList(sourceDir);
Array.print(list);

// loop through files in directory
for (i=0; i<list.length; i++) {
	if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff") ){
    	open(sourceDir + list[i]);
  		// create rectangular selection
    	makeRectangle(cropX, cropY, cropWidth, cropHeight);
    	run("Crop");
    	run("Enhance Contrast...", "saturated=0.9 equalize");
}}

// Create stack from the cropped images
run("Images to Stack", "use");

// Alignment with "Linear Stack Alignment with SIFT"
run("Linear Stack Alignment with SIFT", " minimum_image_size=cropHeight maximum_image_size=cropWidth expected_transformation=Translation interpolate show_info show_transformation_matrix");
selectWindow("Log");
close("*");

// ParseTransformationMatrix() and ParseXY(row) functions from spencer Lab answer: 
// https://forum.image.sc/t/registration-of-multi-channel-timelapse-with-linear-stack-alignment-with-sift/50209/8
var xShift = newArray();
var yShift = newArray();

ParseTransformationMatrix();

Array.print(xShift);
Array.print(yShift);

// Function to parse the transformation matrix from the Log output
function ParseTransformationMatrix(){
	//Get Log Output
	logString = getInfo("log");
	//Subdivide into Rows
	rows=split(logString,"\n");

	for(i=0;i<rows.length;i++){
		if(rows[i].contains("Transformation")){
			ParseXY(rows[i]);
		}
	}
}

// Function to extract X and Y values from the Log output rows
function ParseXY(row){
	split1 = split(row,"[");
	XSplit = split(split1[1],",");
	YSplit = split(split1[2],",");

	XPosTemp = XSplit[2];
	YPosTemp = YSplit[2];
	
	XPos = XPosTemp.substring(0,XPosTemp.length-1);
	YPos = YPosTemp.substring(0,YPosTemp.length-2);

	xShift = Array.concat(xShift,parseFloat(XPos));
	yShift = Array.concat(yShift,parseFloat(YPos));
}

name = ""
function image_naming(hours, delta, chip, output_folder, image_num) { 
	// Converting the data to int
	hours_int = parseInt(hours);
 	delta_int = parseInt(delta);
 	numb = parseInt(image_num);
 	chip_w = File.getNameWithoutExtension(chip);
	// Changing each image name according to its time
	// Saving the images in the correct chip folder
 	a = toString((numb)*delta_int);
 	b = toString(numb);
 	
	if (lengthOf(a)<2) {
		new_name = "0" + a + "h_" + chip_w;
		}
	if (lengthOf(a)>1) {
		new_name =  a + "h_" + chip_w;
		}
		
	// Saving image as tif
	print("Saving image number " + b + " as " + new_name + " in " + output_folder + chip_w + "/" + "   as tiff" );
	saveAs("Tiff", output_folder + new_name);
	 }

// Function to close all open windows and resets ROI Manager
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
		
// Loop over all images in the directory
for (i=1; i<list.length; i++){
    // Check if file is an image
    if (i>0 && (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff"))){
        // Open the image
        open(sourceDir + File.separator + list[i]);
        // Calculate the translation to apply to the image
        xTranslate = xShift[i-1];
        yTranslate = yShift[i-1];
        // Apply the translation to the image
        run("Translate...", "x=" + xTranslate + " y=" + yTranslate + " interpolation=None");
		// Calling naming function
        image_naming(hours, delta, chip, output_folder, i);
		// Closing all the open images
		run("Close All");
    } }
    
// Save the first image
open(sourceDir + File.separator + list[0]);
image_naming(hours, delta, chip, output_folder, 0);
CleanUp();

