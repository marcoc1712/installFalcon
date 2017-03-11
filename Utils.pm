#!/usr/bin/perl
# $Id$
#
# WEB INTERFACE and Controll application for an headless squeezelite
# installation.
#
# Best used with Squeezelite-R2 
# (https://github.com/marcoc1712/squeezelite/releases)
#
# Copyright 2016 Marco Curti, marcoc1712 at gmail dot com.
# Please visit www.marcoc1712.it
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License,
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
################################################################################

package WebInterface::Utils;

use strict;
use warnings;
use utf8;

sub new{
	my $class = shift;
	return $class;
}

sub trim{
    my $class = shift;
    my ($val) = shift;

    if (defined $val) {

    $val =~ s/^\s+//; # strip white space from the beginning
    $val =~ s/\s+$//; # strip white space from the end

        if (! utf8::is_utf8($val)) {

            utf8::upgrade($val);
    	}	
    }
    return $val;         
}
sub executeCommand{
	my $command=shift;

	#some hacking on quoting and escaping for differents Os...
	$command= finalizeCommand($command);

	if ($main::ISDEBUG){
	
            print (qq(execute command  : $command));
            print ($main::isDebug ? 'in debug' : 'production');
	
	} 
	
        my @args =($command);
        exec @args or print("couldn't exec command: $!");	

}
sub finalizeCommand{
    my $command=shift;

    if (!defined $command || $command eq "") {return ""}

    if (main::ISWINDOWS){

        # command could not start with ", should move it after the volume ID.
        if (substr($command,0,1) eq '"'){

            my $str= substr($command,2,length($command)-2);
            my $vol= substr($command,1,1);

            $command=$vol.'"'.$str;
        }
    }
    return $command;
}
1;

