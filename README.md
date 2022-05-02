# schielb-gps-sdr-sim
Credit where it's due, all work in the osqzss-gps-sdr-sim folder is located at https://github.com/osqzss/gps-sdr-sim

This is just a repository that subtree's osqsss's work and adds scripting to it.

## MAJOR SECURITY REQUIREMENT!!! READ THIS BEFORE COMMITTING/PUSHING ANYTHING!
In order to access the information on NASA's website, an account will need to be made. If you don't have an account, you can start the process very easily by clicking [here](https://cddis.nasa.gov/archive/gnss/data/daily/).

Once you have a login and password, you need create a new file in the main repository; this should be called '.netrc'. Copy the following line into it:

```machine urs.earthdata.nasa.gov login <login> password <password>```

And then replace \<login> and \<password> with your credentials. Once you have made it and saved it, make sure that it is not going to be committed or pushed when you try to update the repository on your end. There is a line in the .gitignore that should accomplish this.

I'd highly recommend making a randomly-generated password and storing that in this .netrc file. Security on this password cannot be guaranteed (someone could always delete the line in the .gitignore file and hope you pull/push without realizing). The bad that can be done with this password is very limited (all data is publicly available, the government just keeps track of who is accessing what), but that doesn't mean that it's nothing.