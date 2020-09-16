
roiManager("Add");
name = getTitle();

open();//Gfactorの画像を開く
Gfactor = getImageID();

selectWindow(name);
run("Split Channels");
selectWindow(name + " (blue)");
close();

selectWindow(name + " (red)");
red = getImageID();

selectWindow(name + " (green)");
green = getImageID();

selectImage(red);
roiManager("Select", 0);
run("Crop");
run("Z Project...", "start=1 stop=40 project=[Average Intensity]");
run("32-bit");
croppedRed = getImageID();

selectImage(green);
roiManager("select", 0);
run("Crop");
run("Z Project...", "start=1 stop=40 project=[Average Intensity]");
run("32-bit");
croppedGreen = getImageID();

selectImage(Gfactor);
roiManager("Select", 0);
run("Crop");
croppedGfactor = getImageID();

roiManager("Delete");

imageCalculator("Multiply create 32-bit", croppedRed, Gfactor);
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
run("Analyze Particles...", "clear add");

selectImage(GP);
roiManager("Measure");
roiManager("Delete");
close("\\Others");