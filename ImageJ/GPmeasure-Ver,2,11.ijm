/*
 * -UPDATE-
 * Ver.1.00 19.11.6
 * Ver.1.01 19.11.7
 * ・Laurdan-add画像を保存するか否かを選択できるように変更
 * ・back-GPを測定できるように変更
 * Ver.1.02 19.11.8
 * ・GP画像を作成する際にバックを引かないように変更
 * ver.1.03 19.11.11
 * ・ROIをすべて消去してしまった際、処理が停止する不具合を解決
 * ・誤字を修正
 * ver.2.00 19.11.18
 * ・Laurudanの蛍光の座標も求められるようになり、処理方法を大幅に変更
 * ver.2.10 19.11.26
 * ・S650の蛍光座標の取り方を変更
 * ver.2.11 19.11.27
 * ・切り出したROIからAddとbackAddを測定し比較できるように変更
 */

/*
 * GP画像と処理したROIを出力します。
 * G-factorを作成するためのDMSO-Laurdanの重ね合わせ画像を最初に要求します。
 * 処理するStella650とLaurdan長波長,Laurdan短波長の画像を重ね合わせた画像のみを入れたファイルを用意してください。
 * 保存先は重ね合わせ画像を用意したファイル以外にしてください。
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
AddpathList = newArray(count);
run("Set Measurements...", "area mean min centroid redirect=None decimal=3");

startframe = getNumber("重ね合わせを開始するフレーム",1);
stopframe = getNumber("重ね合わせを終了するフレーム",30);
pncLaurdan = getNumber("Laurdanの和画像から輝点を抽出する際のprominence値",4);
pncS650 = getNumber("S650の蛍光画像から輝点を抽出する際のprominence値",2);

need = getBoolean("Laurdanのadd画像を保存しますか?");
if(need) File.makeDirectory(output + "/add");
if(need) backAdd = getBoolean("抽出したROIをaddとaddの180°回転したものに当てはめ、精度を確認しますか?");

blotNeed = getBoolean("Laurdanの蛍光の座標画像を保存しますか?");
if(blotNeed) File.makeDirectory(output + "/blotOfLaurdan");

S650Need = getBoolean("選別前のS650のROIを保存しますか?");
if(S650Need) File.makeDirectory(output + "/ROI-of-S650");

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
	blue = getImageID();

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
		saveAs("tiff", output + "/GP/" + nameOfoverlay + "-GP.tif");
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
		if(need){
			saveAs("tiff", output + "/add/" + nameOfoverlay + "-add.tif");
			AddpathList[i] = output + "/add/" + nameOfoverlay + "-add.tif";
		}

//add画像のLaurdanの輝点の存在する箇所を求め、画像を作成する
		getDimensions(width, height, channels, slices, frames);
		run("Find Maxima...", "prominence=pncLaurdan output=List");

		cntlist = getValue("results.count");

		newImage("LaurdanBlot", "8-bit black", width, height, 1);

		roiManager("Deselect");
		run("Subtract...", "value = 255");

		for(u = 0; u < cntlist; u++){
			x = getResult("X", u);
			y = getResult("Y", u);
			makeRectangle(x-1, y-1, 3, 3);
			roiManager("add");
			roiManager("select", u);
			run("Add...", "value=255");
		}

		laurdanBlot = getImageID();
		selectImage(laurdanBlot);
		laurdanBlotName = getTitle();
		if(blotNeed) saveAs("tiff", output + "/blotOfLaurdan/" +  laurdanBlotName + "-" + i + ".tif");
		run("Clear Results");
		roiManager("Delete");
		roiManager("Delete");

//Stella650画像の処理を行う
	selectImage(blue);

//LaurdanとS650のMergeを確認する
	run("Find Maxima...", "prominence=pncS650 output=List");

	cntlist = getValue("results.count");

	for(u = 0; u < cntlist; u++){
		x = getResult("X", u);
		y = getResult("Y", u);
		makeRectangle(x-1, y-1, 3, 3);
		roiManager("add");
	}
	if(S650Need) roiManager("Save", output + "/ROI-of-S650/" + "ROI-of-S650-" + i + ".zip");
	
	selectImage(laurdanBlot);
	roiManager("Measure");

	q = 0;
	for(u = cntlist-1; u > -1; u--){
		 f = getResult("Mean",u);
		 if(f==0){
		 	roiManager("select",u);
		 	roiManager("Delete");
		 	q += 1;
		 }
	}
	
//G-factor画像以外の画像を閉じる
	selectImage(Gfactor);
	close("\\Others");
	
//ROIをすべて消去してしまった際に処理が停止することを防止する
	if(q != cntlist){
		roiManager("Save", output + "/roi/" + nameOfoverlay + "-roi.zip");
		RoipathList[i] = output + "/roi/" + nameOfoverlay + "-roi.zip";
		roiManager("delete");
	}
	else{
		RoipathList[i] = "nothing";
	}
	run("Clear Results");
}
close();

//保存した結果を呼び出し、測定を行い保存する
//add画像から測定する
if(backAdd){
	for(i = 0; i < count; i++){
		open(AddpathList[i]);
		if(RoipathList[i] != "nothing"){
			roiManager("open", RoipathList[i]);
			roiManager("Show ALL");
			roiManager("Measure");
			roiManager("delete");
		}
		close();
	}
}

if(backAdd){
	saveAs("Results", output + "Add-Value.csv");
	run("Clear Results");
}

//add画像のbackを測定する
if(backAdd){
	for(i = 0; i < count; i++){
		open(AddpathList[i]);
		run("Flip Horizontally");
		run("Flip Vertically");
		if(RoipathList[i] != "nothing"){
			roiManager("open", RoipathList[i]);
			roiManager("Show ALL");
			roiManager("Measure");
			roiManager("delete");
		}
		close();
	}
}

if(backAdd){
	saveAs("Results", output + "Add-back-Value.csv");
	run("Clear Results");
}

//バックグラウンドのGPを測定する
if(backGP){
	for(i = 0; i < count; i++){
		open(GPpathList[i]);
		run("Flip Horizontally");
		run("Flip Vertically");
		if(RoipathList[i] != "nothing"){
			roiManager("open", RoipathList[i]);
			roiManager("Show ALL");
			roiManager("Measure");
			roiManager("delete");
		}
		close();
	}
}

if(backGP){
	saveAs("Results", output + "back-GP-Value.csv");
	run("Clear Results");
}

//GPを測定する
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