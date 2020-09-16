/*
 * -UPDATE-
 * Ver.1.00 19.11.6
 * Ver.1.01 19.11.7
 * ・Laurdan-add画像を保存するか否かを選択できるように変更
 * ・back-GPを測定できるように変更
 */

/*
 * GP画像と処理したROIを出力します。
 * G-factorを作成するためのDMSO-Laurdanの重ね合わせ画像を最初に要求します。
 * 処理するStella650とLaurdan長波長,Laurdan短波長の画像を重ね合わせた画像のみを入れたファイルを用意してください。
 * 保存先は重ね合わせ画像を用意したファイル以外にしてください。
 * 
 * 2値化処理が上手くいっていないと感じる際は82行目を修正してください
 */

//処理データの入力を行う
open(); //DMSO-Laurdanの重ね合わせ画像を開いてください
output = getDirectory("保存先を選んでください");
overlay = getDirectory("重ね合わせ画像の入ったファイルを選択してください");
File.makeDirectory(output + "/roi");
File.makeDirectory(output + "/GP");
overlaylist = getFileList(overlay);
count = overlaylist.length;
GPpathList = newArray(count);
RoipathList = newArray(count);
run("Set Measurements...", "area mean min centroid redirect=None decimal=3");

startframe = getNumber("重ね合わせを開始するフレームを入力",1);
stopframe = getNumber("重ね合わせを狩猟するフレームを入力",30);

need = getBoolean("Laurdanのadd画像を保存しますか?");
if(need) File.makeDirectory(output + "/add");

backGP = getBoolean("バックのGP値を測定しますか?");

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
	run("Z Project...", "projection=[Average Intensity]"); //Stella650の8-bit 1F aviが作成された
	
	run("Threshold...");
	setAutoThreshold("Yen dark"); //2値化処理
	run("Convert to Mask");
	run("Analyze Particles...","clear add");
	
//Stella650-particleの重心を求め、重心を中心とする3x3の正方形のROIを作成する
	HowMany = roiManager("count");

	roiManager("Measure");
	
	for(u = HowMany - 1; u > -1; u--){
		x = getResult("X", u);
		y = getResult("Y", u);
		makeRectangle(x - 1, y - 1, 3, 3);
		roiManager("add");
		roiManager("select", u);
		roiManager("Delete");
	}
		close();
		close();
		run("Clear Results");

//GP画像を作成する
		run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]"); //現在(green)が一番前にある
		ModeGreen = getValue("Mode");
		setMinAndMax(ModeGreen,255);
		run("Apply LUT");
		
		selectWindow(nameOfoverlay + " (red)"); //(red)を一番前に
		run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");
		ModeRed = getValue("Mode");
		setMinAndMax(ModeRed,255);
		run("Apply LUT");

		imageCalculator("Multiply create 32-bit","AVG_" + nameOfoverlay + " (red)",Gfactor);
		imageCalculator("Add create 32-bit", "AVG_" + nameOfoverlay + " (green)","Result of AVG_" + nameOfoverlay + " (red)");
		add = getImageID();
		if(need) saveAs("tiff", output + "/add/" + nameOfoverlay + "-add.tif");
		imageCalculator("Substract create 32-bit", "AVG_" + nameOfoverlay + " (green)","Result of AVG_" + nameOfoverlay + " (red)");
		sub = getImageID();
		imageCalculator("Divide create 32-bit",sub,add);
		GP = getImageID();
		saveAs("tiff", output + "/GP/" + nameOfoverlay + "-GP.tif");
		GPpathList[i] = output + "/GP/" + nameOfoverlay + "-GP.tif";

//backGroundの値を定める
		selectImage(add);
		nameOfAdd = getTitle();
		run("Copy");
		run("Internal Clipboard");
		LaurdanCopy = getImageID();
		run("Flip Horizontally");
		run("Flip Vertically");
		roiManager("Deselect");
		roiManager("Show None");
		roiManager("Show ALL");
		roiManager("Measure");
		HowMany = roiManager("count");

		a = HowMany * 19 / 20; //95%以上で作成している
		where = a - (a % 1); //整数化

		valueList = newArray(HowMany);

		for(n = 0; n < HowMany; n++){
			valueList[n] = getResult("Mean", n);
		}

		Array.sort(valueList);
		threshold = valueList[where];
		run("Clear Results");

//Laurdanの輝点が重ならない点を削除しROIを保存する
//G-factor画像以外の画像を閉じる
		selectImage(add);
		roiManager("Show All");
		roiManager("measure");
		
		for(m = HowMany - 1; m > -1; m--){
			Value = getResult("Mean",m);
			if(Value < threshold){
				roiManager("Select", m);
				roiManager("Delete");
			}
		}
	selectImage(Gfactor);
	close("\\Others");
	roiManager("Save", output + "/roi/" + nameOfoverlay + "-roi.zip");
	RoipathList[i] = output + "/roi/" + nameOfoverlay + "-roi.zip";
	roiManager("delete");
	run("Clear Results");
}
close();

//保存した結果(GPとROI)を呼び出し測定を行い、まとめて保存する
if(backGP){
	for(i = 0; i < count; i++){
		open(GPpathList[i]);
		run("Flip Horizontally");
		run("Flip Vertically");
		roiManager("open", RoipathList[i]);
		roiManager("Show ALL");
		roiManager("Measure");
		roiManager("delete");
		close();
	}
}

if(backGP){
	saveAs("Results", output + "back-GP-Value.csv");
	run("Clear Results");
}

for(i = 0; i < count; i++){
	open(GPpathList[i]);
	roiManager("open", RoipathList[i]);
	roiManager("Show ALL");
	roiManager("Measure");
	roiManager("delete");
	close();
}

saveAs("Results", output + "GP-Value.csv");
run("Clear Results");