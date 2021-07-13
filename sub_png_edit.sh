#! /bin/bash
all=`grep "<div begin" manifest_ttml.xml` | wc-l
read -p "Width:" Width
read -p "Height:" Height
i=1

grep "<div begin" manifest_ttml2.xml  | sed 's/.*tts:extent=".*" .*"\([1-9].*\)".*/\1/'| sed 's/px//g' | while read line ; do

px=`identify -format "%[width]" ${i}.png`
py=`identify -format "%[height]" ${i}.png`

ox=`echo "$line" | cut -d " " -f 1`
oy=`echo "$line" | cut -d " " -f 2`

Ladd=$ox
Tadd=$oy
Radd=$(( Width - px - ox ))
Badd=$(( Height - py -oy ))

#echo "Width $Width Height $Height px $px py $py ox $ox oy $oy Ladd $Ladd Tadd $Tadd Radd $Radd Badd $Badd"
printf "\r%s" "${i}/${all}"

convert ${i}.png -background none -gravity southeast -splice ${Radd}x${Badd} ${i}.png
convert ${i}.png -background none -gravity northwest -splice ${Ladd}x${Tadd} ${i}.png

i=$(( i + 1 ))

done
# w(1920) h(1080) px(672) py(152) ox(624) oy(820)
# Ladd=ox Tadd=oy Radd=w-px-ox Badd=h-py-oy
# 624           820             624                      108

# identify -format "%[width] %[height]" 3.png
# grep "<div begin" manifest_ttml2.xml  | sed 's/.*tts:extent="\(.*\)" .*"\([1-9].*\)".*/\1 \2/'| more
# convert 1.png -background none -gravity southeast -splice ${Radd}x${Badd} 1.png
# convert 1.png -background none -gravity northwest -splice ${Ladd}x${Tadd} 1.png
