#!/usr/bin/wish

button .hello -text Hello -command {puts stdout "Hello, World!"}

button .goodbye -text Bye! -command {exit}

pack .hello -padx 60 -pady 5

pack .goodbye -padx 60 -pady 5