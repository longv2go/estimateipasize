#!/bin/bash

EXECUTE_PATH=`pwd` #执行目录

CURRENT_PATH=`dirname $0` #脚本所在目录
CURRENT_PATH=`cd $CURRENT_PATH && pwd`


echo_err()
{
    echo $1 >&2
}

usage()
{
    echo "cmd PATH_TO_DIR "
    exit 1
}

# 输入ipa的绝对地址
process_ipa()
{
    echo $1
    echo $2
    pushd .
    tmp_dir=/tmp/out_tmp
    if [ -d $tmp_dir ];then
        rm -rf $tmp_dir/*
    fi
    mkdir -p $tmp_dir

    cd $tmp_dir
    unzip -o "$1" -d $tmp_dir

    cd Payload/`ls Payload`

    if [ ! -e Info.plist ];then
        return 
    fi
    app_name=$(plutil -p Info.plist|grep CFBundleExecutable |awk '{print $3}'|awk -F \" '{print $2}')

    orig_size=$(wc -c $app_name |awk '{print $1}')


    if [ ! -e $app_name ];then
        return 
    fi

    archs=$(lipo -info $app_name)
    zip -q /tmp/a.zip $app_name
    zip_size=$(wc -c /tmp/a.zip | awk '{print $1}')
    if [ -e /tmp/a.zip ];then
        rm /tmp/a.zip
    fi

    popd 

    scale=$(echo "scale=2; $orig_size/$zip_size" |bc)
    echo "$zip_size|$orig_size|$scale  $archs" >> $2
}

if [ $# -ne 1 ];then
    echo $#
    usage 
fi

OUT_TXT=$EXECUTE_PATH/out.txt

cd "$1"

ls *ipa | while read x; do 
    file="$1/$x"
    process_ipa "$file" $OUT_TXT
done

#计算压缩比的平均值
tmp_out=/tmp/out.txt
if [ -e $tmp_dir ];then
    rm $tmp_out
fi
cat $OUT_TXT | awk '{print $1}' | awk -F \| '{print $3}' > $tmp_out

#平均值
sort -n $tmp_out | sed -n '1!p' |sed -n '$!p' | awk '{a+=$1} END{print a/NR}'





