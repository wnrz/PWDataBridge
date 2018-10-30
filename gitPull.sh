#! /bin/bash
myPath=$1
if [$myPath = ""]; then
myPath="."
fi
function read_dir(){
for file in `ls $myPath`
do
if [ -d "$myPath/$file" ]; then
if [ -d "$myPath/$file/.git" ]; then
echo "进入文件\""$file"\""
cd $file
echo "pull git开始"
git pull
echo "pull git结束"
echo "退出文件\""$file"\""
echo "***************************************************"
cd ..
fi
fi
done
}

read_dir $1
