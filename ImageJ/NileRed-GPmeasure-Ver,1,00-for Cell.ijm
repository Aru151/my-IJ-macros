//Nileredの画像解析を想定
//RTMから作成された.datファイルを用いて、RTM Distortion Correctionを用いた補正画像を
//短波長側、長波長側両方で用意してください

open(); //補正されたDMSO-NileRedの短波長側の画像を開いてください
DMSOShort = getImageID();
open(); //補正されたDMSO-Nileredの長波長側の画像を開いてください
DMSOLong = getImageID();
gpref = getNumber("GPrefの値を入力してください", -0.34209); //梅林さん:-0.74 私:-0.34209(NR12S),-0.40555(CoA-PEG11-NR)
output = getDirectory("結果を出力する先を選択");
NileredShort = getDirectory("切り取り後のNile redの短波長側の画像が入ったファイル");
NileredLong = getDirectory("切り取り後のNile redの長波長側の画像が入ったファイル");
File.makeDirectory(output + "/GP");
File.makeDirectory(output + "/roi");
File.makeDirectory(output + "/background用のROI");

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

imageCalculator("Add create 32-bit", DMSOIDShort, DMSOIDLong);
DMSOAdd = getImageID();
imageCalculator("Sub create 32-bit", DMSOIDShort, DMSOIDLong);
DMSOSub = getImageID();
imageCalculator("Divide create 32-bit", DMSOSub, DMSOAdd);
GPmes = getImageID();

imageCalculator("Copy create 32-bit",GPmes,GPmes);
run("Multiply...","value=gpref");
GPmesGPref = getImageID();
imageCalculator("Copy create 32-bit",GPmesGPref,GPmesGPref);
run("Add...","value=gpref");
warareru = getImageID();
imageCalculator("Subtract create 32-bit",warareru,GPmes);
run("Subtract...","value=1");
warareruu = getImageID();
imageCalculator("Add create 32-bit",GPmes,GPmesGPref);
run("Subtract...","value=1");
run("Subtract...","value=gpref");
waru = getImageID();
imageCalculator("Divide create 32-bit",warareruu,waru);
Gfactor = getImageID();

//main function
for(i = 0; i < count; i++){
	//短波長側を開き、画像の名前を所得、輝度を平均した画像を所得しImageIDを所得
	open(NileredShort + NileredShortList[i]);
	nameOfShort = getTitle();
	run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");
    ShortID = getImageID();

    //長波長側を開き、画像の名前を所得、輝度を平均した画像を所得しImageIDを所得
	open(NileredLong + NileredLongList[i]); 
	nameOfLong = getTitle();
	run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");
	LongID = getImageID();

    //輝度を平均化した画像のadd画像を所得
	imageCalculator("Add create 32-bit", ShortID, LongID);
	addImage = getImageID();
	
/*	
//バックグラウンドを除く操作
//所得したadd画像中の輝点を検出し、周囲を10*10のRoiで区切る
//周囲9方向の最も小さい値をbackgroundとして中心の領域から引く
selectImage(addImage);
run("Find Maxima...", "prominence=30 output=List");
cntlist = getValue("results.count");
pathlist = newArray(cntlist);

for(u = 0; u < cntlist; u++){
	x = getResult("X", u);
	y = getResult("Y", u);
	makeRectangle(x-10, y-10, 20, 20);
	roiManager("add");
	
	makeRectangle(x-10, y-35, 20, 20);
	roiManager("add");
	makeRectangle(x-10, y+15, 20, 20);
	roiManager("add");
	makeRectangle(x-35, y-10, 20, 20);
	roiManager("add");
	makeRectangle(x+15, y-10, 20, 20);
	roiManager("add");
	makeRectangle(x-35, y-35, 20, 20);
	roiManager("add");
	makeRectangle(x+15, y-35, 20, 20);
	roiManager("add");
	makeRectangle(x+15, y+15, 20, 20);
	roiManager("add");
	makeRectangle(x-35, y+15, 20, 20);
	roiManager("add");

	roiManager("Save", output + "/background用のROI/" + nameOfShort + "-" + u + "-roi.zip");
	pathlist[u] = output + "/background用のROI/" + nameOfShort + "-" + u + "-roi.zip";

	roiManager("Delete");
}
run("Clear Results");

pathlistcount = pathlist.length;

for(s = 0; s < pathlistcount; s++){
open(pathlist[s]);
selectImage(ShortID);
roiManager("Measure");

b = 255;
for(t = 1; t < 9; t++){
	a = getResult("Mean", t);
	if(a < b) b = a;
}

roiManager("select", 0);
run("Subtract...", "value=b");

selectImage(LongID);
roiManager("Measure");
cntlist = getValue("results.count");

b = 255;
for(t = 1; t < 9; t++){
	a = getResult("Mean", t);
	if(a < b) b = a;
}

roiManager("select", 0);
run("Subtract...", "value=b");
roiManager("Deselect");
roiManager("Delete");

} */

//GP画像を作成する
	selectImage(LongID); //長波長側を一番前へ,32-bit画像に変換
	run("32-bit");
	selectImage(ShortID); //短波長側を一番前へ,32-bit画像に変換
	run("32-bit");

	//Gfactorの導入とGP画像の構築
	imageCalculator("Multiply create 32-bit", LongID, Gfactor);
	LongGfactor = getImageID();
	imageCalculator("Subtract create 32-bit", ShortID, LongGfactor);
	subtract = getImageID();
	imageCalculator("Add create 32-bit", ShortID, LongGfactor);
	addition = getImageID();
	imageCalculator("Divide create  32-bit", subtract, addition);
	GP = getImageID();

    //mask画像の作成の為にadd画像を作成する
	selectImage(ShortID); //短波長側を一番前に
	run("8-bit");
	ModeGreen = getValue("Mode");
	setMinAndMax(ModeGreen,255);
	run("Apply LUT");
	AVGgreen = getImageID();
		
	selectImage(LongID); //長波長側を一番前に
	run("8-bit");
	ModeRed = getValue("Mode");
	setMinAndMax(ModeRed,255);
	run("Apply LUT");
	AVGred = getImageID();

	imageCalculator("Add create 32-bit", AVGgreen, AVGred);
	add = getImageID();
	if(need) saveAs("tiff", output + "/add/" + nameOfShort + "-add.tif");

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

	imageCalculator("Multiply create 32-bit", GP, mask);
	saveAs("tiff", output + "/GP/" + nameOfShort + "-GP.tif");
	GPpathList[i] = output + "/GP/" + nameOfShort + "-GP.tif";

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