//Laurdanの短波長、長波長の順で重ね合わせたaviファイルを使用
//事前に処理するファイルのみをまとめたファイルを作成しておいてください

//入力を行う
output = getDirectory("処理後のファイルはどこに保存しますか?");
overlay = getDirectory("処理する重ね合わせ画像のみの入ったファイル");

File.makeDirectory(output + "/Add");
File.makeDirectory(output + "/binary");

startframe = getNumber("蛍光強度のaveragingを開始するフレームを半角で入力",1);
stopframe = getNumber("蛍光強度のaveragingを終了するフレームを半角で入力",150);

//処理を行うファイルでリストを作成、リストの要素数を求める
overlaylist = getFileList(overlay);
count = overlaylist.length;
AddList = newArray(count);
GPList = newArray(count);
NameList = newArray(count);

//リストの要素数の回数分だけファイルの上からGP画像を作成する処理を行う
for(i = 0; i < count; i++) { 			
	open(overlay + overlaylist[i]);
	name = getTitle();
	NameList[i] = name;
	run("Split Channels");
	close();
	run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");		//現在(green)が一番前にある
	selectWindow(name + " (red)");
	run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");
	imageCalculator("Add create 32-bit", "AVG_" + name + " (green)","AVG_" + name + " (red)");
	add = getImageID();
	saveAs("tiff", output + "/Add/" + name + "-add.tif");
	AddList[i] = output + "/Add/" + name + "-add.tif";
	imageCalculator("Substract create 32-bit", "AVG_" + name + " (green)","AVG_" + name + " (red)");
	sub = getImageID();
	imageCalculator("Divide create 32-bit",sub,add);
	saveAs("tiff", output + name + "-GP.tif");
	GPList[i] = output + name + "-GP.tif";
	run("Close All");
}

for(i = 0; i < count; i++){
	open(AddList[i]);
	run("Threshold...");
	setAutoThreshold("Yen dark"); //2値化処理
	run("Convert to Mask");
	saveAs("tiff", output + "/binary/" + "binary-" + NameList[i] + ".tif");
	close("*");
}
