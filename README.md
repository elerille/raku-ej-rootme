# Ej::RootMe
Raku module for access to API of api.www.root-me.org.

# Examples

Full documentation in [Documentation.md](Documentation.md)

## Instantiation
You can access to api with your API key (https://www.root-me.org/?page=preferences), your `spip_session` cookie.
The API can get a `spip_session` with your credentials (login and password).
```perl6
my Ej::RootMe $root-me .= new: api-key => "...";
my Ej::RootMe $root-me .= new: spip-session => "...";
my Ej::RootMe $root-me .= new: login => "...", password => "...";
```

## Ej::RootMe::Challenge

```perl6
# lazy list of all challenge
my Challenge @all-challenge = $root-me.challenges;

my Challenge $challenge = @all-challenge[0];

# load all information about challenge
$challenge.load;

# lazy list of challenge in french
my Challenge @challenge-fr = $root-me.challenges: :lang<fr>;

# challenge #5
my Challenge $challenge5 = $root-me.challenge(5);
```

Filter for `$root-me.challenges` : `titre`, `soustitre`, `lang`, `score`

## Ej::RootMe::Auteur

```perl6
# lazy list of all author
my @all-author = $root-me.auteurs;

# load all information about author
@all-author[0].load;

# lazy list of author in french
my @author-fr = $root-me.auteurs: :lang<fr>;

# author #5
my $author5 = $root-me.auteur(5);

# lazy list of all author in order of score DESC
my @classement = $root-me.classement;
```
Filter for `$root-me.auteurs` : `nom`, `status`, `lang`

## Ej::RootMe::EnvironnementVirtuel

```perl6
# lazy list of all author
my @all-environnement-virtuel = $root-me.nvironnements-virtuels;

# load all information about EnvironnementVirtuel
@all-environnement-virtuel[0].load;

# author #5
my $environnement-virtuel5 = $root-me.environnement-virtuel(5);
```
