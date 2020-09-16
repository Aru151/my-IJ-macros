//Laurdanの短波長、長波長、Stella650の蛍光の順でRTMで重ね合わせたaviファイルを使用
//事前に処理するファイルのみをまとめたファイルを作成しておいてください
//Laurdanの長波長側と短波長側の蛍光を足した画像も作成します。Stellaの蛍光との重なりの判定に使用します

/* DMSO-LaurdanのGP画像を開いておいてください
 * その画像をもとにGfactor画像を作成し補正を行います
 */

/*Fijiのバグにより処理するファイルと保存するファイルが同一のものでないと動作しません。
 *今後のアップデートに期待します。
 *また、それにより処理を行うファイル内のデータを[日付時刻]で古いものを上にソートしなければ
 *正しく動作できません。
 */

//GPmes画像のimgeIDを所得する
gpmes = getImageID();
name = getTitle();
gpref = 0.207;

//Gfactor画像を作成する
imageCalculator("Copy create 32-bit",gpmes,gpmes);
run("Multiply...","value=0.207");
gpmesgpref = getImageID();
imageCalculator("Copy create 32-bit",gpmesgpref,gpmesgpref);
run("Add...","value=0.207");
warareru = getImageID();
imageCalculator("Subtract create 32-bit",warareru,gpmes);
run("Subtract...","value=1");
warareruu = getImageID();
imageCalculator("Add create 32-bit",gpmes,gpmesgpref);
run("Subtract...","value=1.207");
waru = getImageID();
imageCalculator("Divide create 32-bit",warareruu,waru);
gfactor = getImageID();
close("\\Others");

//入力を行う
overlay = getDirectory("処理する重ね合わせ画像のみの入ったファイル");
output = getDirectory("処理後のファイルはどこに保存しますか?");

//allframe = getNumber("処理を行うavi一つあたりの総フレーム数を半角で入力");　//現在は不要なコマンド
startframe = getNumber("蛍光強度のaveragingを開始するフレームを半角で入力",1);
stopframe = getNumber("蛍光強度のaveragingを終了するフレームを半角で入力",150);

//処理を行うファイルでリストを作成、リストの要素数を求める
overlaylist = getFileList(overlay);
count = overlaylist.length;


//リストの要素数の回数分だけファイルの上からGP画像を作成する処理を行う
//S650の蛍光強度はすべてのフレームで合算している
for(i = 0; i < count; i++) { 			
	open(overlaylist[i]);
	name = getTitle();
	run("Split Channels");
	run("Z Project...", "projection=[Average Intensity]");
	saveAs("tiff", output + "averaged-" + name + "-S650.tif");
	close();
	close();
	run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");		//現在(green)が一番前にある
	selectWindow(name + " (red)");
	run("Z Project...", "start=startframe stop=stopframe project=[Average Intensity]");
	imageCalculator("Multiply create 32-bit","AVG_" + name + " (red)",gfactor);
	imageCalculator("Add create 32-bit", "AVG_" + name + " (green)","Result of AVG_" + name + " (red)");
	add = getImageID();
	imageCalculator("Substract create 32-bit", "AVG_" + name + " (green)","Result of AVG_" + name + " (red)");
	sub = getImageID();
	imageCalculator("Divide create 32-bit",sub,add);
	saveAs("tiff", output + name + "-GP.tif");
	selectImage(add);
	saveAs("tiff",output + name + "-add.tif");
	selectImage(gfactor);
	close("\\Others");
}
close();