use strict;
use warnings;

use Test2::V0;
use Test2::Tools::PerlCritic;
use Test2::Require::AuthorTesting;
 
perl_critic_ok 'lib', 'test library files';
perl_critic_ok 't',   'test test files';
 
done_testing;
