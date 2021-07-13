#! /bin/bash
#処理経過表示用変数
all=`grep "<div begin" manifest_ttml2.xml | wc -l `

#動画解像度入力
read -p "Video Width:" Width
read -p "Video Height:" Height
#比較用変数
WH=`echo "${Width}${Height}"`
#ループ用変数
i=1

#xmlで定義された画面解像度
extentx=`grep "<tt" manifest_ttml2.xml | sed 's/.*extent="\(.*\)px".*/\1/' | sed s/px// | cut -d " " -f 1`
extenty=`grep "<tt" manifest_ttml2.xml | sed 's/.*extent="\(.*\)px".*/\1/' | sed s/px// | cut -d " " -f 2`
#比較用変数
extentxy=`echo "${extentx}${extenty}"`

#動画とxmlで解像度が違う場合あらかじめpngの大きさ調整(比率が小さいほうに合わせる)
if [ ${WH} = ${extentxy} ] ; then
	echo "video and xml resolution is match"
else
	echo "video and xml resolution is unmatch"
	#縦横解像度差の倍率を計算
	scalex=`echo "scale=5;${Width}/${extentx}*100" | bc`
	scalex=`printf "%.0f" $scalex`
	scaley=`echo "scale=5;${Height}/${extentxy}*100" | bc`
	scaley=`printf "%.0f" $scaley`
	#比率が小さいほうを判定
	if [ ${scalex} -gt ${scaley} ] ; then
		scaling=${scalex}
	else
		scaling=${scaley}
	fi
	#echo ${scaling}
	#pngの解像度を調整
	for i in `seq 1 ${all}` ;do
		printf "\r%s" "${i}/${all}"
		convert "${i}.png" -geometry "${scaling}%" "${i}.png"
	done
	i=1
fi

#xmlを一行づつ読んで画像処理
grep "<div begin" manifest_ttml2.xml  | sed 's/.*tts:extent=".*" .*"\([1-9].*\)".*/\1/'| sed 's/px//g' | while read line ; do

#pngのサイズ取得
px=`identify -format "%[width]" ${i}.png`
py=`identify -format "%[height]" ${i}.png`

#配置位置を設定
ox=`echo "$line" | cut -d " " -f 1`
ox=`echo "scale=5;${ox}/${extentx}*$Width" | bc`
ox=`printf "%.0f" ${ox}`

oy=`echo "$line" | cut -d " " -f 2`
oy=`echo "scale=5;${oy}/${extenty}*$Height" | bc`
oy=`printf "%.0f" ${oy}`

#上下左右の余白量を設定
Ladd=$ox
Tadd=$oy
Radd=$(( $Width - $px - $ox ))
Badd=$(( $Height - $py - $oy ))

#echo "Width $Width Height $Height px $px py $py ox $ox oy $oy Ladd $Ladd Tadd $Tadd Radd $Radd Badd $Badd"
#echo "$(($Ladd+$Radd+$px)) $(($Tadd+$Badd+$py))"
#進捗表示
printf "\r%s" "${i}/${all}"

#画像編集
convert ${i}.png -background none -gravity southeast -splice ${Radd}x${Badd} ${i}.png
convert ${i}.png -background none -gravity northwest -splice ${Ladd}x${Tadd} ${i}.png

i=$(( i + 1 ))

done
# w(1920) h(1080) px(672) py(152) ox(624) oy(820)
# Ladd=ox Tadd=oy Radd=w-px-ox Badd=h-py-oy
# 624		820		624			 108

# identify -format "%[width] %[height]" 3.png
# grep "<div begin" manifest_ttml2.xml  | sed 's/.*tts:extent="\(.*\)" .*"\([1-9].*\)".*/\1 \2/'| more
# convert 1.png -background none -gravity southeast -splice ${Radd}x${Badd} 1.png
# convert 1.png -background none -gravity northwest -splice ${Ladd}x${Tadd} 1.png
#ox/extentx*Width
#oy/extenty*Height
