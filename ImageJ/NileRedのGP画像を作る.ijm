//処理データの入力を行う
open(); //DMSO-NileRedの重ね合わせ画像を開いてください
output = getDirectory("保存先を選んでください");
overlay = getDirectory("重ね合わせ画像の入ったファイルを選択してください");
File.makeDirectory(output + "/GP");
overlaylist = getFileList(overlay);
count = overlaylist.length;
GPpathList = newArray(count);

//run("Set Measurements...", "area mean min centroid redirect=None decimal=3");

startframe = getNumber("重ね合わせを開始するフレームを入力",1);
stopframe = getNumber("重ね合わせを終了するフレームを入力",30);

need = getBoolean("NileRedのadd画像を保存しますか?");
if(need) File.makeDirectory(output + "/add");

//G-factorを求める
nameOfDMSO = getTitle();
run("Split Channels");
close();
run("Z Project...","projection=[Average Intensity]");
DMSOIDShort = getImageID();
DMSOnameShort = getTitle();
selectWindow(nameOfDMSO + " (red)");
run("Z Project...","projection=[Average Intensity]");
DMSOIDLong = getImageID();
DMSOnameLong = getTitle();

gpref = 0.207;

imageCalculator("Add create 32-bit", DMSOIDShort, DMSOIDLong);
DMSOAdd = getImageID();
imageCalculator("Sub create 32-bit", DMSOIDShort, DMSOIDLong);
DMSOSub = getImageID();
imageCalculator("Divide create 32-bit", DMSOSub, DMSOAdd);
GPmes = getImageID();

imageCalculator("Copy create 32-bit",GPmes,GPmes);
run("Multiply...","value=0.207");
GPmesGPref = getImageID();
imageCalculator("Copy create 32-bit",GPmesGPref,GPmesGPref);
run("Add...","value=0.207");
warareru = getImageID();
imageCalculator("Subtract create 32-bit",warareru,GPmes);
run("Subtract...","value=1");
warareruu = getImageID();
imageCalculator("Add create 32-bit",GPmes,GPmesGPref);
run("Subtract...","value=1.207");
waru = getImageID();
imageCalculator("Divide create 32-bit",warareruu,waru);
Gfactor = getImageID();

//main function
for(i = 0; i < count; i++){
	open(overlaylist[i]);
	nameOfoverlay = getTitle();
	run("Split Channels"); //(blue)が一番前

	close();

//GP画像を作成する
		selectWindow(nameOfoverlay + " (green)"); //現在(green)が一番前にある
		run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");
		AVGgreen = getImageID();
		selectWindow(nameOfoverlay + " (red)"); //(red)を一番前に
		run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");
		AVGred = getImageID();
		imageCalculator("Multiply create 32-bit", AVGred, Gfactor);
		AVGredGfactor = getImageID();
		imageCalculator("Subtract create 32-bit", AVGgreen, AVGredGfactor);
		subtract = getImageID();
		imageCalculator("Add create 32-bit", AVGgreen, AVGredGfactor);
		addition = getImageID();
		imageCalculator("Divide create  32-bit", subtract, addition);
		GP = getImageID();
		GPpathList[i] = output + "/GP/" + nameOfoverlay + "-GP.tif";

//add画像を作成する
		selectImage(AVGgreen);
		ModeGreen = getValue("Mode");
		setMinAndMax(ModeGreen,255);
		run("Apply LUT");
		AVGgreen = getImageID();
		
		selectImage(AVGred); //(red)を一番前に
		ModeRed = getValue("Mode");
		setMinAndMax(ModeRed,255);
		run("Apply LUT");
		AVGred = getImageID();

		imageCalculator("Add create 32-bit", AVGgreen, AVGred);
		add = getImageID();
		if(need) saveAs("tiff", output + "/add/" + nameOfoverlay + "-add.tif");

		run("8-bit");
		run("Threshold...");
		setAutoThreshold("Otsu dark"); //2値化処理
		run("Convert to Mask");
		run("Divide...", "value=255");
		mask = getImageID();

		imageCalculator("Multiply create 32-bit", GP, mask);
		saveAs("tiff", output + "/GP/" + nameOfoverlay + "-GP.tif");

	selectImage(Gfactor);
	close("\\Others");
}
close();