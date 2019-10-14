# xpp-matlab
XPP-Matlab legacy interface

_Text taken from the former home page of this tool:_ https://web.archive.org/web/20190716100158/http://www2.gsu.edu/~matrhc/XPP-Matlab.html

# An elementary [XPP](http://www.math.pitt.edu/~bard/xpp/xpp.html)-Matlab interface

While I was a teaching assistant for the 2004 Woods Hole "Methods in Computational Neuroscience" course I found that some of the students wanted to do sophisticated parameter sweeps and other tricks with their XPP simulations. In response, I wrote some basic Matlab functions that can change XPP .ode and .set files and run XPP externally to Matlab.

## Important usage notes
Thanks to Sherry Linn at the University of Pittsburgh for some updates for usage with Macs.

Keep backups of all your original `.ode` and `.set` files before letting any program (especially mine) stomp all over them!

The interface works only with versions of Matlab later than R13. If you want to try fixing the code for R12 or R11 yourself I expect the only thing you'll have to do is declare the following two variables at the beginning of every .m file provided in the package: `true = 1; false = 0;`

Please note that you may have to specify the full path to the XPP executable (in the 4th argument to the call to RunXPP) in order to get Matlab to run XPP. On Linux/OS X, depending on your installation, execute `which xpp` or `which xppaut`. On windows, look at the file properties for your shortcut to winPP or xppwin.

On modern 64-bit Intel Macs, you may have to make the following change to line 29 of RunXPP.m: the string `MAC` -> `MACI64`.

On line 65 of RunXPP.m you may need to change the string `!xppaut -silent` to be `!./xppaut -silent`

On Macs and linux, you may find that the line-ending styles get messed up whenever the program ChangeXPPodeFile.m alters the .ode file to change the parameters, such that XPP cannot read it. To fix this, you should use the program dos2unix (install if not already on your system) and add the following command to the main program after the execution of ChangeXPPodeFile.m and before the execution of RunXPP.m: eval('!./dos2unix ')

Note about output files: There is currently no facility to change integration parameters or anything that appears after the "@" command. This means that the data output will go to the same file after every external run. One way to get around this is to rename the output file after each run so that it won't be overwritten on the next run. This should cause little additional overhead. For instance:

```
root_name = 'out';
for i = 1:10
  < run XPP here >
    movefile('output.dat', [root_name num2str(i) '.dat'])
    end
```

## Version updates
Version 070626 (26 June 2007):

* Added platform-specific line terminators to ChangeXPPodeFile.m and ChangeXPPsetFile.m
(\n for linux, unix, and OS X, and \r\n for windows)
* Updated error messages to be generated using the Matlab `error` command
* Added better check for termination of XPP (thanks to Michael Rempe for this)
* Changed the Mac OS X execution of xpp from using `!` command to `system`
Unfortunately some of these changes are untested so please alert me to any problems.

## Other utilities included
Also included in the download is a function to generate an array of spike times (or more generally, arbitrary threshold crossings) from simulation data, and an example script showing how these functions can be used to generate a 3D plot of a neuron's firing frequency response from varying two parameters simultaneouly. Documentation is included in the download, and can also be read online here.

## Rationale
I have found these functions very useful for a variety of computational problems, although they are no feat of programming or imagination on my part. Essentially, these functions let you call XPP in "silent mode" from within Matlab, and let you change parameter values or initial conditions within your .ode or .set files. Running XPP in silent mode means that it dumps its output to an ASCII-format file which can be easily loaded back into Matlab for analysis.

This may sound like a long-winded and slow process, but XPP typically integrates your models faster than the native Matlab DE solvers, and the models are more intuitively specified using XPP anyway (in my opinion). I have found there to be minimal overhead involved in having my functions change parameters by automatically editing the .ode or .set files in situ, or loading modestly sized data files from a hard drive.

This interface can be useful to Matlab users for a variety of reasons:

(a) If you are not an advanced XPP user, and you don't understand how to set up multi-parameter / initial condition (I.C.) range integration batch jobs in XPP, or you find doing so too fussy and prone to mistakes. You may want to vary more than 2 parameters or I.C.s. without specifying a large table of pre-determined values within XPP, or you want to allow a user to set up the ranges interactively in Matlab.

(b) Furthermore, you might want to run Matlab scripts that adaptively select parameter values or I.C.s based on the results of previous XPP integration results (e.g. parameter estimation algorithms, "shooting" methods, etc.).

(c) You can do data analysis on the integrated orbits without writing dynamic link libraries (usually in C) that are called from within your .ode script. (Some institutional installations of XPP may not have been done with the DLL option set, which can be a problem.) Also, you can take advantage of Matlab's built-in statistical tools and visualization capabilities.

(d) You don't need an X server on a Windows platform to run XPP in silent mode, so I guess these functions might make XPP a little more usable in the event that you don't have a working X server in Windows!
