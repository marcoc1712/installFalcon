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

package Status;

use strict;
use warnings;
use utf8;

my %gravityMap = (
   
   0 => 'OK',
   1 => 'DEBUG',
   2 => 'DETAILS',
   3 => 'INFO',
   4 => 'RESULT',
   5 => 'WARNING',
   6 => 'UNEXPECTED',
   7 => 'ERROR',
   8 => 'SEVERE',
   9 => 'FATAL',
);

my %revGravityMap = reverse %gravityMap;

sub new{   
    my $class = shift;
    my $verbosity = shift || 0;
    
    my %lines = ();
    
    my $self = bless {
       _startedAt     => time,
       _gravity       => 0,
       _message       => '',
       _lines         => \ %lines,
       _verbosity     => $verbosity,
        
    }, $class;
    
    $self->{_utils}   =  Utils->new($self);
    
    $self->record("START",4, "Installer started ad ".$self->getUtils()->getNiceTimeString($self->getUtils()->getTimestamp()).
                             " in ".$self->_gravityCodeToDesc($verbosity)." mode",'');
    
    return $self;
}

sub getVerbosity{
    my $self = shift;
    
    return $self->{_verbosity};
}

sub isDebug{
    my $self = shift;

    return ($self->getVerbosity() < 2);
}
sub getUtils{
    my $self = shift;
    
    return $self->{_utils};
}
################################################################################
sub record {
    my $self    = shift;  
    
    my $command = shift;
    my $gravity = shift;
    my $message = shift;
    my ($details) = shift || '';

    my ($package, $filename, $line, $subroutine) = caller(1);
        
    #my $id = $filename." line: ".$line.;
    
    my $id = $self->getUtils()->getTimestamp();

    $gravity=$self->_gravityDescToCode($gravity);

    $self->{_lines}->{$id}->{'time'}        =$self->getUtils()->getNiceTimeString($id);
    $self->{_lines}->{$id}->{'package'}     =$package;
    $self->{_lines}->{$id}->{'filename'}    =$filename;
    $self->{_lines}->{$id}->{'line'}        =$line;
    $self->{_lines}->{$id}->{'subroutine'}  =$subroutine;
    $self->{_lines}->{$id}->{'command'}     =$command;
    $self->{_lines}->{$id}->{'gravity'}     =$gravity;
    $self->{_lines}->{$id}->{'message'}     =$message;
    $self->{_lines}->{$id}->{'details'}     =$details;
    
    if ($gravity > $self->{_gravity}){

        $self->{_gravity} = $gravity;
        $self->{_message} = $message;
    }
    if ($self->isDebug() && $self->getVerbosity() le $gravity) { 
        
        #inline printing.
        $self->_print($id,$self->getVerbosity());
    }
}

sub printout{
    my $self = shift;
    my $filter = shift || $self->getVerbosity();
    
    if ($filter < 3 ){$filter = 2} # Debug and details are printed inline.
    
    $filter = $self->_gravityDescToCode($filter);

    my $in = $self->getLines($filter); 

    for my $id (sort keys %$in){

       $self->_print($id,5); 
    }
    
    print "\n";
    
    my $gravity=$self->_gravityDescToCode($self->getGravity());
    
    if ($gravity ge $filter){
        print "STATUS : ".$self->getGravity()."\n";
        if ($self->getMessage()){print "MESSAGE: ".$self->getMessage()."\n";}
        print "\n"
    
    } else {
    
        print"ENDED with no errors\n\n";
    } 

}
sub wasStartetAt{
    my $self = shift;
    
    return $self->{_startedAt};
}

sub getGravity{
    my $self = shift;

    return $self->_gravityCodeToDesc($self->{_gravity});
}

sub getMessage{
    my $self = shift;
    
    return $self->{_message};
}

sub getLines{
    my $self = shift;
    my $filter = shift || $self->getVerbosity();
    
    $filter =  $self->_gravityDescToCode($filter);
    
    my $in = $self->{_lines};
    my %filtered=();
    my $out = \%filtered;
    
    for my $id (keys %$in){
        
        if ($self->{_lines}->{$id}->{'gravity'} ge $filter){
        
            $out->{$id}->{'origin'}  = $self->{_lines}->{$id}->{'origin'};
            $out->{$id}->{'command'} = $self->{_lines}->{$id}->{'command'};
            $out->{$id}->{'gravity'} = $self->_gravityCodeToDesc($self->{_lines}->{$id}->{'gravity'});
            $out->{$id}->{'message'} = $self->{_lines}->{$id}->{'message'};
            $out->{$id}->{'details'} = $self->{_lines}->{$id}->{'details'};
        }
        
    }
    return $out;
}
##################################################################################
sub _gravityDescToCode{
    my $self = shift;
    my $gravity= shift;
    
    if (!$gravity){return 0;}
    if (exists $revGravityMap{$gravity}){return $revGravityMap{$gravity};}
    if (exists $gravityMap{$gravity}){ return $gravity;}
    
    if (_isAnumber($gravity)){
         
        my $int = int($gravity);    
        if (exists $gravityMap{$int}){return $gravity;}
    }
    $self->record('','FATAL', $gravity." is not a vailid gravity",_getCaller());
    return 9;#fatal
}

sub _gravityCodeToDesc{
    my $self = shift;
    my $gravity= shift;
    
    if (!$gravity){return 'OK';}
    if (exists $gravityMap{$gravity}){return $gravityMap{$gravity};}
    
    if (_isAnumber($gravity)){
         
         my $int = int($gravity);
    
        if (!$int){return 'OK';}
        if (exists $gravityMap{$int}){return $gravityMap{$int};}
        if (exists $revGravityMap{$int}){return $int;}
        
    }
    
    if (exists $revGravityMap{$gravity}){return $gravity;}
    
    $self->record('','FATAL', $gravity." is not a vaild gravity",_getCaller());
    return 'FATAL';
    
}

sub _isAnumber{
    local $_ = shift;
    
    if (/^-?(?:\d+(?:\.\d*)?|\.\d+)$/) {return 1};
    return 0;
}

sub _getCaller{
    
    my ($package, $filename, $line, $subroutine) = caller(2);
     
    my $out= " ORIGNED AT:\n".
             "   - Package    : ".($package ? $package :"")."\n".
             "   - Filename   : ".($filename ? $filename :"")."\n".
             "   - Line       : ".($line ? $line :"")."\n".
             "   - Subroutine : ".($subroutine ? $subroutine :"")."\n";
    
    return $out;
}

sub _print{
    my $self = shift;
    my $id = shift;
    my $filter = shift || $self->getVerbosity();
    
    if ($self->{_lines}->{$id}->{'gravity'} > $filter){
        
        $self->_printDetailed($id);
        
    } else {
       
       $self->_printLine($id);
    }
}

sub _printDetailed{
    my $self = shift;
    my $id = shift;
    
    print " - Time       : ".$self->{_lines}->{$id}->{'time'}."\n";
    print " - Package    : ".$self->{_lines}->{$id}->{'package'}."\n";
    print " - Filename   : ".$self->{_lines}->{$id}->{'filename'}."\n";
    print " - Line       : ".$self->{_lines}->{$id}->{'line'}."\n";
    print " - Subroutine : ".$self->{_lines}->{$id}->{'subroutine'}."\n";
    print " - Command    : ".$self->{_lines}->{$id}->{'command'}."\n";
    print " - Gravity    : ".$self->_gravityCodeToDesc($self->{_lines}->{$id}->{'gravity'})."\n";
    print " - Message    : ".$self->{_lines}->{$id}->{'message'}."\n";
    print " - Details    : ".$self->{_lines}->{$id}->{'details'}."\n";
    print "\n";
    
}
sub _printLine{
    my $self = shift;
    my $id = shift;
    
    print $self->{_lines}->{$id}->{'time'}." ".
          $self->{_lines}->{$id}->{'subroutine'}." "." line: ".$self->{_lines}->{$id}->{'line'}." ".
          $self->_gravityCodeToDesc($self->{_lines}->{$id}->{'gravity'}).": ".
          $self->{_lines}->{$id}->{'message'}."\n";  
}
1;

