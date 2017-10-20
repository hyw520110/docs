rm -rf 28002.conf 28003.conf
cp 28001.conf 28002.conf
cp 28001.conf 28003.conf
sed -i "s/28001/28002/g" 28002.conf
sed -i "s/28001/28003/g" 28003.conf
