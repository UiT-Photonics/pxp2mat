## pxp2mat
simple wrapper for the [igor2](https://github.com/AFM-analysis/igor2) package that converts [Igor Pro](https://www.wavemetrics.com/products/igorpro) "packed experiments", i.e. .pxp files, into mat files (matlab files). It's extremely basic, it only handles scalar values and wave records but at least you can get the data out.

Also includes a matlab script to plot all the waves records.

### HOWTO
download the pxp2mat.py file, make it executable, run it with one or more pxp-files as argument(s). It outputs mat-files in the same folder with the same name but with the file extension changed to .mat.

#### example
This assumes you have downloaded pxp2mat.py to ~/Downloads and have a pxp file in there called my_igor_data.pxp as well
```bash
cd ~/Downloads
chmod +x pxp2mat.py
./pxp2mat.py my_igor_data.pxp
```


