

number = roiManager("Count");
index = number;
Nilered = getImageID();
name = getTitle();

selectWindow(name);
run("Split Channels");
selectWindow(name + " (blue)");
close();

selectWindow(name + " (red)");
run("Z Project...", "start=1 stop=40 project=[Average Intensity]");
redA = getImageID();

selectWindow(name + " (green)");
run("Z Project...", "start=1 stop=40 project=[Average Intensity]");
greenA = getImageID();

open();//Gfactorの画像を開く
GfactorA = getImageID();

for(i = 0; i < number; i++) {

	/*selectImage(Nilered);
	imageCalculator("Copy create",Nilered,Nilered);
	name = getTitle();

	selectImage(GfactorA);
	imageCalculator("Copy create",GfactorA,GfactorA);
	Gfactor = getImageID();*/

	
	
	selectImage(redA);
	imageCalculator("Copy create",redA,redA);
	roiManager("Select", i);
	run("Crop");
	
	run("32-bit");
	croppedRed = getImageID();
	
	selectImage(greenA);
	imageCalculator("Copy create",greenA, greenA);
	roiManager("select", i);
	run("Crop");
	
	run("32-bit");
	croppedGreen = getImageID();
	
	selectImage(GfactorA);
	imageCalculator("Copy create",GfactorA,GfactorA);
	roiManager("Select", i);
	run("Crop");
	croppedGfactor = getImageID();
	
	imageCalculator("Multiply create 32-bit", croppedRed, croppedGfactor);
	croppedRedG = getImageID();
	
	imageCalculator("Add create 32-bit", croppedGreen, croppedRedG);
	Add = getImageID();
	imageCalculator("Subtract create 32-bit", croppedGreen, croppedRedG);
	Sub = getImageID();

	imageCalculator("Divide create 32-bit", Sub, Add);
	GP = getImageID();
	
	//マスク用の二値化画像を作成する
	selectImage(Add);
	setAutoThreshold("Otsu dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "add");
	
	selectImage(GP);
	roiManager("select", index);
	roiManager("Measure");
	roiManager("Delete");
	
	close(croppedRed);
	close(croppedGreen);
	close(croppedGfactor);
	close(croppedRedG);
	close(Add);
	close(Sub);
	close(GP);
}

roiManager("Delete");
close("*");