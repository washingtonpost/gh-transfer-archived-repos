use Modern::Perl '2020';

use Test2::V0;

use Test2::Require::AuthorTesting;
use Test2::Require::EnvVar 'GITHUB_ACCESS_TOKEN';
use Test2::Require::EnvVar 'GITHUB_USER_ORG';
use Test2::Tools::Compare qw/T F E U D/;

use Data::Dumper;
use Finder;

use feature qw(signatures);
## no critic (ProhibitSubroutinePrototypes)
no warnings 'experimental::signatures';


my %seen_repos = ();

# This function will only match archived results
my $find_archived   = sub ($result) { return !!$result->{isArchived} };
my $find_unarchived = sub ($result) { return !$result->{isArchived} };

my $t = Finder->new(org => $ENV{'GITHUB_USER_ORG'});

# Find an archived result
my $result = $t->find_matching_repository($find_archived);
say "I got a result: " . Dumper(result => $result);
is $result,
    { name                => T(),
      isArchived          => 1,
      nameWithOwner       => T(),
      viewerCanAdminister => T(),
    },
    q{It should be an archived repository.};
$seen_repos{ $result->{nameWithOwner} } = 1;

# Find an unarchived result
$result = $t->find_matching_repository($find_unarchived);
say "I got another result: " . Dumper(result => $result);
is $result,
    { name                => T(),
      isArchived          => 0,
      nameWithOwner       => T(),
      viewerCanAdminister => T(),
    },
    q{It should be an UNarchived repository.};
ok !exists $seen_repos{ $result->{nameWithOwner} },
    q{We shouldn't have seen this repo yet.};
$seen_repos{ $result->{nameWithOwner} } = 1;

for my $x (0 .. 60) {
  my $last_repo = $result->{nameWithOwner};
  is $last_repo, T(), q{The repo name isn't empty.};
  $result = $t->find_matching_repository($find_archived);
  is $result,
      { name                => T(),
        isArchived          => 1,
        nameWithOwner       => T(),
        viewerCanAdminister => T(),
      },
      'Result looks usable.';
  isnt($result->{nameWithOwner}, $last_repo, q{We didn't get the same repo.});
  ok !exists $seen_repos{ $result->{nameWithOwner} },
      q{We shouldn't have seen this repo yet.};
  $seen_repos{ $result->{nameWithOwner} } = 1;
}

done_testing;

