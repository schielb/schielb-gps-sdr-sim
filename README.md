# schielb-gps-sdr-sim
Credit where it's due, all work in the osqzss-gps-sdr-sim folder is located at https://github.com/osqzss/gps-sdr-sim

This is just a repository that subtree's osqsss's work and adds scripting to it.

## MAJOR SECURITY REQUIREMENT!!! READ THIS BEFORE COMMITTING/PUSHING ANYTHING!
In order to access the information on NASA's website, an account will need to be made. If you don't have an account, you can start the process very easily by clicking [here](https://cddis.nasa.gov/archive/gnss/data/daily/). If you want to just use the lab's credentials, they are located on Notion.

Once you have a login and password, you need to create a new file in the main repository; this should be called '.netrc'. Copy the following line into it:

```machine urs.earthdata.nasa.gov login <login> password <password>```

And then replace \<login> and \<password> with your credentials. Once you have made it and saved it, make sure that this .netrc file is not going to be committed or pushed when you try to update the repository on your end. There is a line in the .gitignore that should accomplish this.

I'd highly recommend making a randomly-generated password and storing that in this .netrc file. Security on this password cannot be guaranteed (someone could always delete the line in the .gitignore file and hope you pull/push without realizing). The bad that can be done with this password is very limited (all data is publicly available, the government just keeps track of who is accessing what), but that doesn't mean that it's nothing.

## BUILDING

You need to build the osqzss code. To do that, simply run the following from the main folder:
```
$ gcc osqzss-gps-sdr-sim/gpssim.c -lm -O3 -o osqzss-gps-sdr-sim/gps-sdr-sim
```

## USAGE
Once you have created and filled in your .netrc file and built the osqzss code, you are ready to run the program. Here is the help dialog:
```
Usage: genAndRun [options]
Options:
  --help            Print this menu.

  --date <day year> Enter the day [1, 366] and year [1992, 2022] of
                    the data you want; keep in mind that the day '366' will
                    only work on a leap year. Typically this option is not
                    needed, as the default is the current date.

  --ll   <lat lon>  Enter the latitude [-90.0, 90.0] and longitude
                    [-180.0, 180.0] that you wish to simulate from. The
                    default location is at the BYU football stadium.

  --sdr  <radio>    Enter the type of software-defined radio hardware you
                    are using; currently only supports 'hackrf' (default)
                    and 'usrp'.

  --just <step>     If 'just' one step is desired, enter it here. Steps are:
                    'gen': gather a brdc file and generate the .bin
                    'run': run the current .bin on the desired sdr
```

This program can run both the generation of the sdr radio data and the application of the actual sdr. A look behind the scenes and all the different commands (if you would like to modify the script) can be found in the README in the osqzss-gpr-sdr-sim folder.

## Hardware

Something like a smartphone might be too smart to get fooled by a spoofed GPS signal, so I had to get some dumber hardware.

Specifically I looked for a simple USB GPS antenna, a good and inexpensive one being [the VK-162 G-Mouse here on Amazon](https://www.amazon.com/VK-162-G-Mouse-External-Navigation-Raspberry/dp/B01EROIUEW). This will just plug into a computer and start uploading NMEA messages based on any GPS transmissions it receives. While these can simply be read on a terminal using something like ```sudo cat /dev/<usb port>```, I used an open source python GPS gui, found at https://github.com/semuconsulting/PyGPSClient The instructions for installing and using this repository are on its readme. If you are using Windows, you can just use the u-center app [here](https://www.u-blox.com/en/product/u-center). Each of these should be able to automatically detect the G-mouse module, and you can start reading its NMEA messages and get a visual image of where you "are" in the world.
