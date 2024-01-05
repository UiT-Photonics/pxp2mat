## pxp2mat
Simple wrapper for the [igor2](https://github.com/AFM-analysis/igor2) package that converts [Igor Pro](https://www.wavemetrics.com/products/igorpro) "packed experiments", i.e. .pxp files, into mat files (matlab files). It's extremely basic, it only handles scalar values and wave records but at least you can get the data out.

Also includes a matlab script to plot all the wave records of the ouput struct.

### HOWTO
Download the pxp2mat.py file, make it executable, run it with one or more pxp-files as argument(s). It outputs mat-files in the same folder with the same name but with the file extension changed to .mat.

#### Example
This example assumes you are running macos/freebsd/linux/something similar, sorry don't have windows computer to test on.

First you need to install the igor2 and scipy packages. While the latter is likely to be handled by your package manager the former is very unlikely to be, so pip is your best bet. Open a terminal and run
```bash
pip install igor2 scipy
```

Then i assume you have downloaded pxp2mat.py to ~/Downloads and have a pxp file in there called my_igor_data.pxp. Open your terminal and run
```bash
# change directory to your Downloads folder
cd ~/Downloads
# make the pxp2mat script executable
chmod +x pxp2mat.py
# run it (replace my_igor_data.pxp with whatever file(s) you have)
./pxp2mat.py my_igor_data.pxp
```


### Why?
I needed to look at the data in some pxp-files and the CLI of igor2 wasn't really working (at that time, don't know the state of it now).

