//Nileredの画像解析を想定
//RTMから作成された.datファイルを用いて、RTM Distortion Correctionを用いた補正画像を
//短波長側、長波長側両方で用意してください

open(); //補正されたDMSO-NileRedの短波長側の画像を開いてください
DMSOShort = getImageID();
open(); //補正されたDMSO-Nileredの長波長側の画像を開いてください
DMSOLong = getImageID();
output = getDirectory("結果を出力する先を選択");
NileredShort = getDirectory("切り取り後のNile redの短波長側の画像が入ったファイル");
NileredLong = getDirectory("切り取り後のNile redの長波長側の画像が入ったファイル");
File.makeDirectory(output + "/GP");
File.makeDirectory(output + "/roi");

NileredShortList = getFileList(NileredShort);
NileredLongList = getFileList(NileredLong);
count = NileredShortList.length;

GPpathList = newArray(count);
RoipathList = newArray(count);

startframe = getNumber("重ね合わせを開始するフレームを入力",1);
stopframe = getNumber("重ね合わせを終了するフレームを入力",30);

need = getBoolean("NileRedのadd画像を保存しますか?");
if(need) File.makeDirectory(output + "/add");

//G-factorを求める
selectImage(DMSOShort);
run("Z Project...","projection=[Average Intensity]");
DMSOIDShort = getImageID();
DMSOnameShort = getTitle();
selectImage(DMSOLong);
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
	open(NileredShort + NileredShortList[i]); //短波長側を開く
	nameOfoverlay = getTitle();

//GP画像を作成する
	selectWindow(nameOfoverlay);
	run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");
	AVGgreen = getImageID();
	open(NileredLong + NileredLongList[i]); //長波長側を開く
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

//add画像を作成する
	selectImage(AVGgreen); //短波長側を一番前に
	ModeGreen = getValue("Mode");
	setMinAndMax(ModeGreen,255);
	run("Apply LUT");
	AVGgreen = getImageID();
		
	selectImage(AVGred); //長波長側を一番前に
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
	run("Analyze Particles...","clear add");
	run("Divide...", "value=255");
	mask = getImageID();

	roiManager("Save", output + "/roi/" + nameOfoverlay + "-roi.zip");
	RoipathList[i] = output + "/roi/" + nameOfoverlay + "-roi.zip";
	roiManager("delete");

	imageCalculator("Multiply create 32-bit", GP, mask);
	saveAs("tiff", output + "/GP/" + nameOfoverlay + "-GP.tif");
	GPpathList[i] = output + "/GP/" + nameOfoverlay + "-GP.tif";

	selectImage(Gfactor);
	close("\\Others");
}
close();

for(i = 0; i < count; i++){
	open(GPpathList[i]);
	if(RoipathList[i] != "nothing"){
		roiManager("open", RoipathList[i]);
		roiManager("Show ALL");
		roiManager("Measure");
		roiManager("delete");
	}
	close();
}

saveAs("Results", output + "GP-Value.csv");
run("Clear Results");