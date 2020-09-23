cellW=1024
cellH=1024

# 处理单个图片
function process() {
    local file=$1                         #完整路径             /Users/***/img/bg.png
    local path=$(dirname $file)           #路径                 /Users/***/img
    local fullname=$(basename $file)      #文件名，包括扩展名     bg.png
    local filename=${fullname%.*}         #文件名               bg
    local exname=${fullname##*.}          #扩展名               png
    #获取宽高
    local w=`convert $file -print "%w"`
    local h=`convert $file -print "%h"`
    if [ $w -lt $cellW ];then
        cellW=$w;
    fi
    if [ $h -lt $cellH ];then
        cellH=$h;
    fi
    #除法运算默认向下取整
    local cellX=$(($w / $cellW))
    local cellY=$(($h / $cellH))
    #向上取整
    if [ $(($w % $cellW)) -ne 0 ];then
        cellX=$((cellX + 1))
    fi
    if [ $(($h % $cellH)) -ne 0 ];then
        cellY=$((cellY + 1))
    fi

    if [ ! -d crop ];then
        mkdir crop
    fi

    #for循环
    for i in $(seq $(($cellX * $cellY)))
    do
        local x=$(((i - 1) % cellX * cellW))
        local y=$((((i - 1) / cellX) * cellH))
        local _cellW=$cellW
        local _cellH=$cellH
        #单独处理每一横行的最后一个元素
        if [ $(($i % $cellX)) -eq 0 ];then
            _cellW=$(($w - ($cellX - 1) * $cellW))
        fi
        #单独处理最后一横行的每一个元素
        if [ $i -gt $((($cellY - 1) * $cellX)) ];then
            _cellH=$(($h - ($cellY - 1) * $cellH))
        fi
        ffmpeg -i $file -vf crop=$_cellW:$_cellH:$x:$y -an "$path/crop/$filename-$i.$exname"
    done
}

# 获取 shell 脚本绝对路径
root=$(cd "$(dirname "$0")";pwd)
res=`find $root -name "*.jpg" -o -name "*.JPG" -o -name "*.jpeg" -o -name "*.JPEG" -o -name "*.png" -o -name "*.PNG"`
# res=`find $root -regex ".*\.jpg\|.*\.png"`
# res=`find $root -regextype posix-extended -regex ".*\.(jpg|jpeg|JPG|JPEG|png|PNG)"`
for file in $res
do
    echo $file
    process $file 
done
