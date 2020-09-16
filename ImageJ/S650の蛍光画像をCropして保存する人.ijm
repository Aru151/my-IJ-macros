//S650の蛍光画像をあらかじめ用意したROIでトリミングします
//あらかじめROIにCropする部分のROiを3番目に開いておいてください。
//(1番目と2番目にはLaurdanの蛍光画像のものが入っていることを想定している為)
//また、処理を行うS650のaviファイルのみをまとめたファイルを用意してください。

output = getDirectory("処理後のファイルはどこに保存しますか?");
S650 = getDirectory("処理するStella650の蛍光画像のみの入ったファイル");
S650list = getFileList(S650);
count = S650list.length;

for(i = 0; i < count; i++) {
	open(S650list[i]);
	name = getTitle();
	roiManager("select",2);
	run("Crop");
	saveAs("avi",output + name + "-S650.avi");
	close();
}