#!/bin/bash

orig_ipa_size=$(wc -c $1 | awk '{print $1}')

tmp_dir=/tmp/out_tmp_est
if [ -d $tmp_dir ];then
    rm -rf $tmp_dir/*
fi
mkdir -p $tmp_dir

cd $tmp_dir
unzip -o -q "$1" -d $tmp_dir

cd Payload/`ls Payload`

if [ ! -e Info.plist ];then
    return 
fi
app_name=$(plutil -p Info.plist|grep CFBundleExecutable |awk '{print $3}'|awk -F \" '{print $2}')

orig_size=$(wc -c $app_name |awk '{print $1}')


if [ ! -e $app_name ];then
    return 
fi

zip -q /tmp/b.zip $app_name
zip_size=$(wc -c /tmp/b.zip | awk '{print $1}')
if [ -e /tmp/b.zip ];then
    rm /tmp/b.zip
fi


estimated_size=$(echo "$orig_size/1.35" | bc)

echo " orig_size: $orig_size,  est_size: $estimated_size,  zip size: $zip_size, orig_ipa : $orig_ipa_size"
echo ""

echo  "Original Size: $orig_ipa_size " 
estimated_ipa_size=$(echo "$estimated_size - $zip_size + $orig_ipa_size" |bc)
echo  "Estimated AppStore Size: $estimated_ipa_size"

