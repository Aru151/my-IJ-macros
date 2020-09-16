
open(); //補正されたDMSO-NileRedの短波長側の画像を開いてください
DMSOShort = getImageID();
open(); //補正されたDMSO-Nileredの長波長側の画像を開いてください
DMSOLong = getImageID();
output = getDirectory("結果を出力する先を選択");
NileredShort = getDirectory("切り取り後のNile redの短波長側の画像が入ったファイル");
NileredLong = getDirectory("切り取り後のNile redの長波長側の画像が入ったファイル");
File.makeDirectory(output + "/短波長蛍光強度");
File.makeDirectory(output + "/長波長蛍光強度");
File.makeDirectory(output + "/roi");

NileredShortList = getFileList(NileredShort);
NileredLongList = getFileList(NileredLong);
count = NileredShortList.length;

ShortpathList = newArray(count);
LongpathList = newArray(count);
RoipathList = newArray(count);

startframe = getNumber("重ね合わせを開始するフレームを入力",1);
stopframe = getNumber("重ね合わせを終了するフレームを入力",30);

//need = getBoolean("NileRedのadd画像を保存しますか?");
//if(need) File.makeDirectory(output + "/add");

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

for(i = 0; i < count; i++){
	open(NileredShort + NileredShortList[i]);
	nameOfShort = getTitle();
	run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");
	run("32-bit");
	AVGgreen = getImageID();
	saveAs("tiff", output + "/短波長蛍光強度/" + nameOfShort + "-Short.tif");
	ShortpathList[i] = output + "/短波長蛍光強度/" + nameOfShort + "-Short.tif";
	
	open(NileredLong + NileredLongList[i]);
	nameOfLong = getTitle();
	run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");
	Long = getImageID();

	imageCalculator("Multiply create 32-bit", Long, Gfactor);
	AVGred = getImageID();
	saveAs("tiff", output + "/長波長蛍光強度/" + nameOfLong + "-Long.tif");
	LongpathList[i] = output + "/長波長蛍光強度/" + nameOfLong + "-Long.tif";

	//add画像を作成する
	selectImage(AVGgreen); //短波長側を一番前に
	run("8-bit");
	ModeGreen = getValue("Mode");
	setMinAndMax(ModeGreen,255);
	run("Apply LUT");
	AVGgreen = getImageID();
		
	selectImage(AVGred); //長波長側を一番前に
	run("8-bit");
	ModeRed = getValue("Mode");
	setMinAndMax(ModeRed,255);
	run("Apply LUT");
	AVGred = getImageID();

	imageCalculator("Add create 32-bit", AVGgreen, AVGred);
	add = getImageID();

	run("8-bit");
	run("Threshold...");
	setAutoThreshold("Otsu dark"); //2値化処理
	run("Convert to Mask");
	run("Analyze Particles...","clear add");
	run("Divide...", "value=255");
	mask = getImageID();

	roiManager("Save", output + "/roi/" + nameOfShort + "-roi.zip");
	RoipathList[i] = output + "/roi/" + nameOfShort + "-roi.zip";
	roiManager("delete");

	selectImage(Gfactor);
	close("\\Others");
}
close();

for(i = 0; i < count; i++){
	open(ShortpathList[i]);
	if(RoipathList[i] != "nothing"){
		roiManager("open", RoipathList[i]);
		roiManager("Show ALL");
		roiManager("Measure");
		roiManager("delete");
	}
	close();
}

saveAs("Results", output + "Short-Value.csv");
run("Clear Results");

for(i = 0; i < count; i++){
	open(LongpathList[i]);
	if(RoipathList[i] != "nothing"){
		roiManager("open", RoipathList[i]);
		roiManager("Show ALL");
		roiManager("Measure");
		roiManager("delete");
	}
	close();
}

saveAs("Results", output + "Long-Value.csv");
run("Clear Results");