/*
 * Stella650の蛍光画像を二値化し、各particleのサイズをpixel数で15以下まで縮小します
 * 縮小した結果のroiを保存します
 * Stella650の画像だけを入れたファイルを用意しておいて下さい
 * DefaultではYenで二値化しています,変更するためには14行目を変更してください
 */

//ファイルを選択し、file内のListを作成、要素数を求める
Stella650 = getDirectory("Stella650のファイルを選んでください");
list = getFileList(Stella650);
output = getDirectory("保存するファイルを選択してください");

count = list.length;

//Listの要素数だけ画像を選択し開き2値化
for(u = 0; u < count; u++){
	open(list[u]);
	name = getTitle();
	run("Threshold...");
	setAutoThreshold("Yen dark");
	run("Convert to Mask");
	run("Analyze Particles...","clear add");
	
	//particleを15以下まで縮小する
	HowMany = roiManager("count");
	for(i = HowMany -1; i > -1; i--){
		roiManager("Select", i);
		Area = getResult("Area", i);
			while(Area > 15){
				run("Erode");
				roiManager("Delete");
				roiManager("Delete");
				run("Analyze Particles...","clear add");
				roiManager("Select", i);
				Area = getResult("Area", i);
			}
	}
	roiManager("Save",output + name + "-RoiSet.zip");
	close();
	roiManager("Delete");
	roiManager("Delete");
}