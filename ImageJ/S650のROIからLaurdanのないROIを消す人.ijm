/*上下左右反転した画像でROIを重ねて、
//重ねた画像の蛍光強度のmeanのmeanを閾値とします(randm性のあるバックの算出)

//最初に要求するのはMaskの元となるStella650の蛍光です
//次にはLaurdanの蛍光の和画像を要求します*/

//Stella650の蛍光画像を開きroiを記憶します
open();
run("Threshold...");
setAutoThreshold("Yen dark");
run("Convert to Mask");
run("Analyze Particles...","clear add");

HowMany = roiManager("count");

//Laurdanの蛍光画像を開き、コピーを作成し、回転させます
//回転したものにStella650のroiを当てはめ、蛍光強度を測定します
open();
Laurdan = getImageID();
Name = getTitle();
run("Copy");
run("Internal Clipboard");
LaurdanCopy = getImageID();
run("Flip Horizontally");
run("Flip Vertically");
roiManager("Show All");
roiManager("Measure");

//バックグラウンドの値を求めます
Mean = 0;
HowManyy = HowMany;
for(i = 0; i < HowMany; i++){
	Value = getResult("Mean",i);
	if(Value > 0){
		Mean += Value;
	}
	else{
		HowManyy -= 1;
	}
}

MeanMean = Mean / HowManyy;

run("Clear Results");
selectWindow(Name);
roiManager("Show All");
roiManager("measure");

//roiをLaurdanの画像に当てはめ
//バックグラウンドの値以下のroiを削除します
for(i = HowMany - 1; i > -1; i--){
	Value = getResult("Mean",i);
	if(Value < MeanMean){
		roiManager("Select", i);
		roiManager("Delete");
	}
}
close("*");
run("Clear Results");