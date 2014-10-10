package My::Login;
use strict;
use warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(authenticate);
sub authenticate($$){
  my( $username, $pwd ) =@_;
  my $path = "./students/$username";
# Does user exist?
  if( -e $path ){
# Can we open his profile?
# TODO just return 0 if we cant
    open F, "$path/profile.txt" or die "Cant open file=($path) to check pwd";
# Extract his password
    my $line;
    while($line=<F>){
      if( $line =~ /password:/){
        $line = <F>;
        chomp $line;
        $line =~ s/^\s*//;
        if( $line eq $pwd ){
          return 1;
        }
      }
    }
  }
  return 0;
}

1;
