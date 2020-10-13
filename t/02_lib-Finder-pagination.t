use Modern::Perl '2020';

use feature qw(signatures);
## no critic (ProhibitSubroutinePrototypes)
no warnings 'experimental::signatures';

use Test2::V0;

use Test2::Require::AuthorTesting;
use Test2::Require::EnvVar 'GITHUB_ACCESS_TOKEN';
use Test2::Require::EnvVar 'GITHUB_USER_ORG';
use Test2::Tools::Compare qw/T F E U D/;

use Data::Dumper;
use Finder;

my $t      = Finder->new(org => $ENV{'GITHUB_USER_ORG'});
my $result = $t->_next();
say "I got a result: " . Dumper(result => $result);

# Just make sure that we get a hashref back, and that it looks reasonable.
is $result,
    { name                => T(),
      isArchived          => D(),
      nameWithOwner       => T(),
      viewerCanAdminister => T(),
    },
    'Result looks usable.';

for my $x (0 .. 100) {
  my $last_repo = $result->{nameWithOwner};
  is $last_repo, T(), q{The repo name isn't empty.};
  $result = $t->_next();
  is $result,
      { name                => T(),
        isArchived          => D(),
        nameWithOwner       => T(),
        viewerCanAdminister => T(),
      },
      'Result looks usable.';
  isnt($result->{nameWithOwner}, $last_repo, q{We didn't get the same repo.});
}

done_testing;

