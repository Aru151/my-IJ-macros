//S650の蛍光画像をあらかじめ用意したROIでトリミングします
//あらかじめROIにCropする部分のROiを3番目に開いておいてください。
//(1番目と2番目にはLaurdanの蛍光画像のものが入っていることを想定している為)
//また、処理を行うS650のaviファイルのみをまとめたファイルを用意してください。

output = getDirectory("処理後の画像はどこに保存しますか?");
Laurdan = getDirectory("処理するLaurdanの蛍光画像のみの入ったファイル");
LaurdanList = getFileList(Laurdan);
S650 = getDirectory("処理するStella650の蛍光画像のみの入ったファイル");
S650List = getFileList(S650);

File.makeDirectory(output + "crop-Stella650");
File.makeDirectory(output + "crop-Laurdan");

count = S650List.length;

for(i = 0; i < count; i++) {
	open(S650List[i]);
	name = getTitle();
	roiManager("select",2);
	run("Crop");
	saveAs("avi",output + "crop-Stella650/" + name + "-S650.avi");
	close();
}

count = LaurdanList.length;

for(i = 0; i < count; i++){
	open(Laurdan + LaurdanList[i]);
	name = getTitle();
	roiManager("select", 0);
	run("Crop");
	saveAs("avi",output + "crop-Laurdan/" + name + "-Long.avi");
	close();
	open(Laurdan + LaurdanList[i]);
	roiManager("select", 1);
	run("Crop");
	saveAs("avi", output + "crop-Laurdan/" + name + "-Short.avi");
	close();
}
