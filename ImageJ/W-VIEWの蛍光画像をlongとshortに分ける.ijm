//W-VIEWの蛍光画像をあらかじめ用意したROIでトリミングし保存します。
//あらかじめROIにCropする部分のROiを長波長、短波長の順で開いておいてください。
//また、処理を行うW-VIEWのaviファイルのみをまとめたファイルを用意してください。

output = getDirectory("処理後の画像はどこに保存しますか?");
Laurdan = getDirectory("処理するW-VIEWの蛍光画像のみが入ったファイル");
Laurdanlist = getFileList(Laurdan);
count = Laurdanlist.length;
File.makeDirectory(output + "croped");
File.makeDirectory(output + "croped/" + "long");
File.makeDirectory(output + "croped/" + "short");

for(i = 0; i < count; i++) {
	open(Laurdanlist[i]);
	name = getTitle();
	roiManager("select",0);
	run("Crop");
	saveAs("avi",output + "croped/long/" + name + "-Long.avi");
	close();
	open(Laurdanlist[i]);
	roiManager("select",1);
	run("Crop");
	saveAs("avi",output + "croped/short/" + name + "-Short.avi");
	close();
}